require 'entities/protocol'
require_relative 'shared'

module Entities
  module Github
    module Shared

      def origin_timestamp
        { origin_ts: @event.origin_timestamp }
      end

      def author_meta_attribute
        { searchable_author: @event.actor.login }
      end

      def repo_name
        { props: { repo_name: @event.repo.name } }
      end

      def props_origin_author
        if @event.actor
          { 
            props: {
              origin_author_id: @event.actor.id,
              origin_author_username: @event.actor.login,
              origin_author_avatar_url: @event.actor.avatar_url,
            }
          }
        else
          {}
        end
      end

      def with_commons(data)
        data
          .merge(origin_timestamp)
          .merge(author_meta_attribute)
          .deep_merge(repo_name)
          .deep_merge(props_origin_author)
      end
    end
  end
end
