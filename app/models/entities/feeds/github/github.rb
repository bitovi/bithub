module Entities
  module Github
    module SharedBuilders

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

    class Commit < Protocol; end
    class Issue < Protocol; end
    class IssueAction < Protocol; end
    class IssueComment < Protocol; end
    class PullRequest < Protocol; end
    class Push < Protocol; end
    class Watch < Protocol; end
  end
end

require_relative 'types/commit'
require_relative 'types/create'
require_relative 'types/fork'
require_relative 'types/issue'
require_relative 'types/issue_action'
require_relative 'types/issue_comment'
require_relative 'types/pull_request'
require_relative 'types/push'
require_relative 'types/watch'
