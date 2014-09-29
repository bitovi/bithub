module Entities
  module Github

    class Push < Protocol
      include Entities::Github::Referencable

      def find
        @event.push_id && find_by_push_id.where(:parent_id => nil).first
      end

      def build
        built = Entity.new({
          title: "pushed to #{@event.repo.name}",
          url: "https://github.com/#{@event.repo.name}/commit/#{@event.head}",
          origin_id: @event.push_id.to_s,
          origin_ts: @event.origin_timestamp,
          props: {
            origin_author_id: @event.actor.id,
            origin_author_name: @event.actor.login,
            origin_author_avatar_url: @event.actor.avatar_url,
            repo_name: @event.repo.name,
            commit_shas: @event.commit_shas_csv,
          }
        })

        built.props[:references_to] = ""

        built 
      end

      def build_children
        @event.commits.map do |c|
          Entities::Github::Commit.new(@event, c)
            .procure
            .determine
            .group
            .normalize
            .instance
        end
      end
      
      # Finders
      
      def find_by_push_id
        Entity
        .feed('github')
        .type('push')
        .where(origin_id: @event.push_id.to_s)
      end

      def find_by_commit_id
        Entity
        .feed('github')
        .type('push')
        .where("props -> 'commit_shas' LIKE '%#{@event.commit_id}%'")
      end

      private
      def url
        "https://github.com/#{@event.repo.name}/commit/#{@event.head}"
      end

    end

  end
end
