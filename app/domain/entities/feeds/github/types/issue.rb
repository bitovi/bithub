module Entities
  module Github

    class Issue
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [Entities::Github::IssueAction, Entities::Github::IssueComment],
        references: [],
      }

      def procure
        if @payload.issue_id && (entity = find_by_issue_id(@payload.issue_id).first)
          entity
        else
          build
        end
      end

      def procure_parent
      end

      def procure_children
        if @payload.repo_name && @payload.issue_or_pull_req_number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl::Procurer.new(@p)
            .find_by_repo_name_and_number(
              @payload.repo_name,
              @payload.issue_or_pull_req_number
            ).all
          end
        end
      end

      def procure_references
      end

      # Builder
      def build
        @persistor.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.html_url,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            issue_id: @payload.issue_id,
            label_names: @payload.label_names,
            state: @payload.state,
            # action: @payload.action, # IssuePullRequestAction?
          }
        })
      end

      # Finders
      def find_by_issue_id(issue_id)
        @persistor.tagged_with(['github', 'issue'])
        .where("props -> 'issue_id' = '#{issue_id}'")
      end

      def find_by_repo_name_and_number(repo_name, number)
        @persistor.where("props -> 'repo_name' = '#{repo_name}'")
        .where("props -> 'number' = '#{number}'")
        .tagged_with(['github', 'issue'])
      end

      def relationships
        Entities::Github::Issue::Relationships
      end

      private

      def taggify_labels
        if @e.instance.props[:labels]
          input = @e.instance.props[:labels]
          Tagger.new(Tag.labels).find_tags(input)
        else
          []
        end
      end

    end
  end
end
