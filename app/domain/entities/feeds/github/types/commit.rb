module Entities
  module Github

    class Commit < Protocol
      include Entities::Github::Referencable

      def initialize(event, commit_wrapper)
        @event = event
        @commit = commit_wrapper
      end

      def find
        @commit.sha && find_by_commit_sha.first
      end

      def build
        built = Entity.new({
          title: title,
          body: @commit.message,
          url: @commit.url,
          origin_id: @commit.sha,
          origin_ts: @event.origin_timestamp,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            origin_author_avatar_url: @event.actor.avatar_url,
            repo_name: @event.repo.name,
            sha: @commit.sha,
          }
        })

        built.props[:references_to] = ""

        built 
      end

      private

      def title
        "pushed to #{@event.repo.name}"
      end

      def find_by_commit_sha
        Entity
        .feed('github')
        .type('commit')
        .where(origin_id: @commit.sha)
      end
    end

  end
end
