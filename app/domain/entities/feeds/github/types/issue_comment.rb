module Entities
  module Github

    class IssueComment < Protocol
      include Entities::Github::Referencable

      Relationships = {
        upstream: [Entities::Github::Issue, Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def find
        @payload.comment_id && find_by_comment_id.first
      end

      def find_parent
        if @payload.repo_name && @payload.number
          matches = relationships[:upstream].inject([]) do |acc, rl|
            acc.push rl.new(@payload).find_by_repo_name_and_number.first
          end
          matches.compact.first
        end
      end

      # Builder
      def build
        Entity.new({
          title: "commented on issue ##{@payload.number}",
          body: @payload.body,
          url: @payload.html_url,
          origin_ts: @payload.origin_ts,
          props: {
            repo_name: @payload.repo_name,
            number: @payload.number,
            origin_id: @payload.comment_id,
          }
        })
      end

      # Finders
      
      def find_by_comment_id
        Entity.tagged_with(['github', 'issue_comment'])
        .where("props -> 'origin_id' = '#{@payload.comment_id}'")
      end

      def find_by_repo_name_and_number
        Entity
          .tagged_with(['github', 'issue_comment'])
          .where("props -> 'repo_name' = '#{@payload.repo_name}'")
          .where("props -> 'number' = '#{@payload.number}'")
      end

      def relationships
        Entities::Github::IssueComment::Relationships
      end
    end

    PullRequestComment = IssueComment
    
  end
end
