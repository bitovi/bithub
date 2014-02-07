module Events

  class OAuthIdentity
    def initialize(ident)
      @data = ident
    end

    def uid
      @data.uid
    end

    def nickname
      @data.source_data.andand[:nickname]
    end
  end

  module Github
    module Accessors
      module Standard

        def event_id
          source_data.andand[:id]
        end

        def payload
          source_data.andand[:payload]
        end

        def actor
          source_data.andand[:actor]
        end

        def repo
          source_data.andand[:repo]
        end

        def repo_name
          source_data.andand[:repo].andand[:name]
        end

        def actor_id
          actor.andand[:id]
        end

        def actor_login
          actor.andand[:login]
        end

        def actor_gravatar_id
          actor.andand[:gravatar_id]
        end

        def actor_avatar_url
          actor.andand[:avatar_url]
        end

        def origin_ts
          ts_str = source_data.andand[:created_at]
          Time.parse(ts_str).utc
        end

        def referenced_issue_numbers
          body ? body.scan(/#\d+/).uniq.map {|m| m.gsub('#','').to_s} : []
        end
      end

      module Comments
        def comment
          payload.andand[:comment]
        end

        def body
          comment.andand[:body]
        end

        def html_url
          comment.andand[:html_url]
        end

        def comment_id
          comment.andand[:id]
        end
      end

      module Refs
        def ref_type
          payload.andand[:ref_type]
        end

        def ref
          payload.andand[:ref]
        end
      end

      module Labels
        def labels
          issue_or_pull_req.andand[:labels]
        end

        def label_names
          labels.andand.map {|l| l[:name] }.andand.join(',')
        end
      end

      module IssuesPullRequests
        def title
          issue_or_pull_req.andand[:title]
        end

        def body
          issue_or_pull_req.andand[:body]
        end

        def html_url
          issue_or_pull_req.andand[:html_url]
        end

        def number
          issue_or_pull_req.andand[:number]
        end

        def state
          issue_or_pull_req.andand[:state]
        end

        def action
          payload.andand[:action]
        end
      end
    end
  end
end
