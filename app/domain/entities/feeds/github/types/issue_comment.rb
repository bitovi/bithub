module Entities
  module Github

    class IssueComment
      include Entities::Constructable

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def procure
        if @payload.comment_id && (entity = find_by_comment_id(@payload.comment_id).first)
          entity
        else
          build
        end
      end

      def procure_parent
        if @payload.repo_name && @payload.issue_or_pull_req_number
          relationships[:downstream].reduce([]) do |acc, rl|
            acc += rl::Procurer.new(@p)
            .find_by_repo_name_and_number(
              @payload.repo_name,
              @payload.issue_or_pull_req_number
            ).first
          end
        end
      end

      def procure_children
      end

      def procure_references
      end

      # Builder
      def build
        @persistor.new({
          title: "commented on issue ##{@payload.number}",
          body: @payload.body,
          url: @payload.html_url,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            label_names: @payload.label_names,
            comment_id: @payload.comment_id,
          }
        })
      end

      # Finders
      def find_by_comment_id(comment_id)
        @persistor.tagged_with(['github', 'issue_comment'])
        .where("props -> 'comment_id' = '#{comment_id}'")
      end

      def find_by_repo_name_and_number(repo_name, issue_number)
        @persistor.where("props -> 'repo_name' = '#{repo_name}'")
        .where("props -> 'number' = '#{number}'")
        .tagged_with(['github', 'issue_comment'])
      end

      def relationships
        Entities::Github::IssueComment::Relationships
      end
    end

  end
end
