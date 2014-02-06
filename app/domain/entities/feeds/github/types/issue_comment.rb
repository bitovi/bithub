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
          origin_id: @payload.comment_id.to_s,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            repo_name: @payload.repo_name,
            number: @payload.number,
          }
        })
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body
        super
      end

      # Finders

      def find_by_comment_id
        Entity
        .feed('github')
        .type('issue_comment')
        .where(origin_id: @payload.comment_id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('issue_comment')
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
