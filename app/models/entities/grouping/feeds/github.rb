module Grouping
  module Feeds
    class Github

      class NoDataToUpdateIssueException < Exception; end

      def group_github
        begin
          if tag_list.include?('github')
            group_issues_event if tag_list.include?('issues_event')
            group_push_event if tag_list.include?('push_event')
            group_pull_request_event if tag_list.include?('pull_request_event')
            group_issue_comment_event if tag_list.include?('issue_comment_event')
            group_commit_comment_event if tag_list.include?('commit_comment_event')
          end
        rescue NoDataToUpdateIssueException => e
          Rails.logger.info "Missing data; Was not able to update the issue."
        end
        self
      end

      def group_issues_event

        if issue_opener && picrs = previous_closers_and_reopeners
          self.children += picrs + (picrs.map{|picr| picr.children}.flatten).uniq

        elsif issue_closer_or_reopener && pi = previous_issue_instance
          self.parent = pi
          pi.update_self_from_child(self)

          # child events must refer to thread starter, not closer/reopener event
          return self
        end

        if ics = related_issue_comments
          self.children += (ics + ics.collect{|ic| ic.children}.flatten).uniq
        end

        if prs = referencing_pull_requests
          self.children += prs
        end

        if ps = referencing_pushes
          self.children += ps
        end

        self
      end

      def group_pull_request_event
        if prcs = related_pull_request_comments
          self.children += (prcs + prcs.collect{|prc| prc.children}.flatten).uniq
        end
        if pi = referenced_issue
          self.parent = pi
        end
        self
      end

      def group_push_event
        if ccs = related_commit_comments
          self.children += (ccs + ccs.collect{|cc| cc.children}.flatten).uniq
        end
        if pi = referenced_issue
          self.parent = pi
        end
        split_push_event_to_commits
        self
      end

      def group_issue_comment_event
        if pi = related_issue
          self.parent = pi
          pi.update_self_from_child(self)
        elsif pic = first_related_issue_comment
          self.parent = pic
        end
        self
      end

      def group_commit_comment_event
        if pp = related_push
          self.parent = pp
        elsif pcc = first_related_commit_comment
          self.parent = pcc
        end
        self
      end

      def split_push_event_to_commits
        h = ActiveSupport::HashWithIndifferentAccess.new(self.source_data)

        h['payload']['commits'].map do |c|
          e = Event.new_from_crawler(*Event.prepare_commit(c, self))
          e.tag_list += self.tag_list
          e.thread_updated_at = self.thread_updated_at
          e.thread_updated_date = self.thread_updated_date
          e.parent = self
          e.save
          e
        end
      end

      # Helpers and finders

      def related_issue
        if props[:issue_id]
          Event.issues_by_issue_id(props[:issue_id]).order('id').first
        elsif props[:owner_repo] and props[:issue_number]
          Event.issues_by_repo_name_and_issue_number(props[:repo_name], props[:issue_number]).order('id').first
        end
      end

      def previous_issue_instance
        related_issue
      end

      def referenced_issue
        if props[:repo_name] && props[:referenced_issue_number]
          Event.issues_by_repo_name_and_issue_number(props[:repo_name], props[:referenced_issue_number]).first
        end
      end

      def related_push
        Event.pushes_by_commit_sha(props[:commit_sha]).first if props[:commit_sha]
      end

      def referencing_pushes
        if props[:repo_name] and props[:issue_number]
          Event.pushes_by_repo_name_and_referenced_issue_number(props[:repo_name], props[:issue_number]).all
        end
      end

      def referencing_pull_requests
        if props[:repo_name] and props[:issue_number]
          Event.pull_requests_by_repo_name_and_referenced_issue_number(props[:repo_name], props[:issue_number]).all
        end
      end

      def related_issue_comments
        Event.issue_comments_by_repo_name_and_issue_number(props[:repo_name], props[:issue_number]).all if props[:issue_number] && props[:repo_name]
      end

      def related_pull_request_comments
        related_issue_comments
      end

      def related_commit_comments
        if props[:commit_sha]
          Event.commit_comments_by_commit_sha(props[:commit_sha]).all
        elsif props[:commit_shas]
          commit_shas = (props[:commit_shas].is_a?(Array)) ? props[:commit_shas].join(',') : props[:commit_shas]
          Event.commit_comments_by_commit_shas(props[:commit_shas]).all
        end
      end

      def first_related_issue_comment
        Event.issue_comments_by_issue_id(props[:issue_id]).order('origin_ts ASC').first if props[:issue_id]
      end

      def first_related_commit_comment
        Event.commit_comments_by_commit_sha(props[:commit_sha]).order('origin_ts ASC').first if props[:commit_sha]
      end

      def issue_opener
        !!(self.props[:action] == "opened")
      end

      def issue_closer_or_reopener
        !!(self.props[:action] == "reopened" || self.props[:action] == "closed")
      end

      def previous_closers_and_reopeners
        Event.issues_by_issue_id(props[:issue_id]).where("props -> 'action' <> 'opened'").all
      end

      def update_self_from_child(child)
        sd = ActiveSupport::HashWithIndifferentAccess.new(child.source_data)
        has_necessary_data = sd && sd[:payload] && sd[:payload][:issue]

        Rails.logger.info "LOGGER: #update_self_from_child: #{has_necessary_data}"

        if has_necessary_data
          self.title = sd[:payload][:issue][:title]
          self.body = sd[:payload][:issue][:body]
          #self.source_data = sd[:payload][:issue]

          self.props['labels'] = sd[:payload][:issue][:labels].map{|l| l[:name]}.join(',')
          self.props['state'] = sd[:payload][:issue][:state]

          self.determine_tags
          self.determine_category

          self.save
        else
          fail NoDataToUpdateIssueException, "Needs to have source_data with the original issue in the payload"
        end
      end

    end
  end
end
