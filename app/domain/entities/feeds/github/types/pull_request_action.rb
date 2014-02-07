module Entities
  module Github

    class PullRequestAction < IssueAction

      Relationships = {
        upstream: [Entities::Github::PullRequest],
        downstream: [],
        references: [],
      }

      def find
        nil
      end

      # Builder
      def build
        entity = Entity.new({
          title: "Pull Request ##{@payload.number} #{@payload.action}",
          origin_ts: @payload.origin_ts,
          origin_id: @payload.origin_id.to_s,
          props: {
            origin_author_id: @payload.actor_id,
            origin_author_name: @payload.actor_login,
            origin_author_avatar_url: @payload.actor_avatar_url,
            repo_name: @payload.repo_name,
            number: @payload.number,
            state: @payload.state,
            action: @payload.action,
          }
        })
        if @payload.respond_to? :label_names
          entity.props[:label_names] = @payload.label_names
        end
        entity
      end

      # Finders
      def find_by_origin_id
        scope = Entity.feed('github')
        .type(my_type_tag)
        .where(origin_id: @payload.origin_id.to_s)
      end

      def find_by_repo_name_and_number
        Entity
        .feed('github')
        .type('pull_request_action')
        .where("props -> 'repo_name' = '#{@payload.repo_name}'")
        .where("props -> 'number' = '#{@payload.number}'")

      end

      def relationships
        Entities::Github::IssueAction::Relationships
      end
    end

  end
end
