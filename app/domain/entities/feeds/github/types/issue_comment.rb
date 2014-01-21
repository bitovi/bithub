module Entities
  module Github

    class IssueComment
      include Entities::Constructable
      include Entities::Determinable

      attr_reader :instance

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.comment_id && (entity = find_by_comment_id(@payload.comment_id).first)
          @instance = entity
        else
          @instance = build
        end
        self
      end

      def procure_parent
        if @payload.repo_name && @payload.issue_or_pull_req_number
          matches = relationships[:upstream].inject([]) do |acc, rl|
            acc.push rl.new(Entity, @payload)
            .find_by_repo_name_and_number(
              @payload.repo_name,
              @payload.issue_or_pull_req_number
            ).first
          end
          matches.compact.first
        end
      end

      # Builder
      def build
        @persistor.new({
          title: "commented on issue ##{@payload.number}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            repo_name: @payload.repo_name,
            number: @payload.number,
            comment_id: @payload.comment_id,
          }
        })
      end

      # Finders
      
      def find_by_comment_id(comment_id)
        @persistor.tagged_with(['github', 'issue_comment'])
        .where("props -> 'comment_id' = '#{comment_id}'")
      end

      def find_by_repo_name_and_number(repo_name, number)
        @persistor.where("props -> 'repo_name' = '#{repo_name}'")
        .where("props -> 'number' = '#{number}'")
        .tagged_with(['github', 'issue_comment'])
      end

      def relationships
        Entities::Github::IssueComment::Relationships
      end
    end

    PullRequestComment = IssueComment
    
  end
end
