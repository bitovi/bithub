# Require all github types
Dir[File.join('app', 'domain', 'events', 'feeds', 'github', 'types', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end

module Events
  module Github

    module Accessors
      module Standard

        def origin_id
          source_data.andand[:id]
        end

        def origin_event_id
          origin_id
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
          source_data.andand[:name]
        end

        def origin_author_name
          actor.andand[:login]
        end

        def origin_author_id
          actor.andand[:id]
        end

        def origin_author_gravatar
          actor.andand[:gravatar_id]
        end


        def origin_timestamp
          ts_str = source_data.andand[:created_at]
          Time.parse(ts_str).utc
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
      end

      module Refs
        def ref_type
          payload.andand[:ref_type]
        end

        def ref
          payload.andand[:ref]
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

        def labels
          issue_or_pull_req.andand[:labels]
        end

        def label_names
          labels.map {|l| l['name'] }.join(',')
        end

        def action
          payload.andand[:action]
        end
      end
    end




    class Processor
      def initialize(original_hash)
        @data = Events::Payload.new(original_hash)
      end

      def process(original_hash, processed)
        if github_event?(original_hash)
          processed.deep_merge({ meta: { type: @data.type.snake_case }})
        elsif github_issue?(original_hash)
          processed.deep_merge({ meta: { type: 'custom_issue_event' }})
        else
          fail Events::Errors::UnknownTypeException
        end
      end

      def content_digest(original_hash)
        if github_issue?(original_hash)
          Events::Github::CustomIssue::Processor.new(original_hash).content_digest
        elsif github_event?(original_hash)
          Digest::MD5.hexdigest(@data.origin_event_id.to_s + 'github')
        end
      end  

      def events_from_response(response)
        response
      end

      private

      def valid_event?(origin_hash)
        github_event?(origin_hash) || github_issue?(origin_hash)
      end

      def github_event?(event_hash)
        not(event_hash['type'].nil?)
      end

      def github_issue?(issue_hash)
        not(issue_hash['labels'].nil?) && not(issue_hash['state'].nil?) && not(issue_hash['comments'].nil?)
      end

    end

  end
end
