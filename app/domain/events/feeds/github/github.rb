require 'app/domain/events/shared/mappings'

module Events
  module Github

    class Processor
      include Events::Mappings

      def process(original_hash, processed)
        if github_event?(original_hash)
          processed = processed.deep_merge({
            meta: {
              feed: 'github',
              type: original_hash['type'].snake_case,
              origin_id: original_hash['id'],
              origin_author_name: original_hash['actor']['login'],
              origin_author_id: original_hash['actor']['id'],
              origin_author_gravatar: original_hash['actor']['gravatar_id'],
            }
          })
          type_processor(original_hash).new.process(original_hash, processed)
        elsif github_issue?(original_hash)
          type_processor(original_hash).new.process(original_hash, processed)
        else
          fail Events::Errors::UnknownTypeException
        end
      end

      def origin_timestamps(original_hash)
        fail_if_invalid(original_hash)
        Time.parse(datetime_str(original_hash)).utc
      end

      def content_digest(original_hash)
        if github_issue?(original_hash)
          type_processor(original_hash).new.content_digest(original_hash)
        elsif github_event?(original_hash)
          seed = ((original_hash[:id] || original_hash['id']).to_s + 'github')
          Digest::MD5.hexdigest(seed)
        end
      end  

      def events_from_response(response)
        response
      end

      private

      def fail_if_invalid(original_hash)
        fail Events::Errors::InvalidEventException, "can't process event since type is not known" if not(valid_event?(original_hash))
      end

      def datetime_str(original_hash)
        (str = original_hash['created_at']) ? str : (fail Processor::MissingTimestamp, "missing origin timestamps");
      end

      def valid_event?(origin_hash)
        github_event?(origin_hash) || github_issue?(origin_hash)
      end

      def github_event?(event_hash)
        not(event_hash['type'].nil?)
      end

      def github_issue?(issue_hash)
        not(issue_hash['labels'].nil?)
      end

      def type_processor(original_hash)
        if github_event?(original_hash)
          event_type_class = type_mappings(original_hash['type']).gsub('Event', '')
          Events::Github.const_get(event_type_class).const_get('Processor')
        elsif github_issue?(original_hash)
          Events::Github::CustomIssue::Processor
        end
      end
    end

  end
end
