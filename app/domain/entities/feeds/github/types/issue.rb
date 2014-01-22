module Entities
  module Github

    class Issue < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [
          #Entities::Github::Commit,
          #Entities::Github::CommitComment,
          Entities::Github::PullRequest,
          Entities::Github::Issue,
          Entities::Github::IssueComment,
          #Entities::Github::PullRequestComment, # same as IssueComment
        ]
      }

      def procure
        @instance = (@payload.issue_id && (e = find_by_issue_id.first)) ? e : build
        self
      end

      def procure_children
        if @payload.repo_name && @payload.number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl.new(@payload).find_by_repo_name_and_number.all
          end
        end
      end

      def procure_references
        if @payload.repo_name && @payload.number
          relationships[:references].reduce([]) do |acc, rl|
            acc += rl.new(@payload).find_by_repo_name_and_number.all
          end
        end        
      end

      # Builder
      def build
        e = Entity.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            repo_name: @payload.repo_name,
            number: @payload.number,
            issue_id: @payload.issue_id,
            label_names: @payload.label_names,
            state: @payload.state,
            # action: @payload.action, # IssuePullRequestAction?
          }
        })
        e.props.symbolize_keys!
        e
      end

      # Finders
      def find_by_issue_id
        Entity.tagged_with(['github', 'issue'])
        .where("props -> 'issue_id' = '#{@payload.issue_id}'")
      end

      def find_by_repo_name_and_number
        Entity
          .tagged_with(['github', 'issue'])
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .where("props -> 'number' = '#{@payload.number}'")        
      end

      def relationships
        Entities::Github::Issue::Relationships
      end

      private

      def taggify_labels
        if @instance.props[:labels]
          input = @instance.props[:labels]
          Tagger.new(Tag.labels).find_tags(input)
        else
          []
        end
      end

    end
  end
end
