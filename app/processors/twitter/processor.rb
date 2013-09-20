require 'app/processors/commons'

module EventProcessor
  class Twitter
    include Commons

    class NotValidEventException < Exception; end
    attr_reader :is_user_stream

    def initialize(opts)
      @is_user_stream = opts[:is_user_stream]
    end

    def process(event_hash)
      raise NotValidEventException if !valid_event?(event_hash)

      partly_processed_hash = {
        :origin_ts => parse_date(event_hash['created_at']).iso8601,
        :origin_date => parse_date(event_hash['created_at']).strftime("%Y-%m-%d"),
        :source_data => event_hash,
        :meta => {
          :feed => feed
        }
      }

      if is_user_stream? && is_follow_event?(event_hash)
        prepare_user_event(event_hash, partly_processed_hash)
      elsif is_not_user_stream? && is_status_event?(event_hash)
        prepare_public_event(event_hash, partly_processed_hash)
      end
    end

    private
    def prepare_user_event(event_hash, partly_processed_hash)
      partly_processed_hash.deep_merge({
        :title => "followed @#{event_hash['target']['screen_name']}",
        :hash_key => Digest::MD5.hexdigest(event_hash['source']['id_str'] + event_hash['target']['id_str'] + feed),
        :meta => {
          :origin_author_name => event_hash['source']['screen_name'],
          :origin_author_id => event_hash['source']['id'],
          :type => 'follow_event'
        }
      })
    end

    def prepare_public_event(event_hash, partly_processed_hash)
      fully_processed_hash = partly_processed_hash.deep_merge({
        :title => event_hash['text'],
        :hash_key => Digest::MD5.hexdigest(event_hash['id_str'] + feed),
        :url => "https://twitter.com/#{event_hash['user']['screen_name']}/status/#{event_hash['id_str']}",
        :meta => {
          :origin_author_name => event_hash['user']['screen_name'],
          :origin_author_id => event_hash['user']['id'],
          :type => 'status_event',
          :origin_id => event_hash['id'],
          :tweet_id => event_hash['id_str']
        }
      })

      # add original tweet id -> used later for grouping retweets
      fully_processed_hash[:meta][:retweeted_id] = event_hash['retweeted_status']['id_str'] if event_hash['retweeted_status']

      fully_processed_hash
    end

    def is_follow_event?(event_hash)
      event_hash['event'] && (event_hash['event'] == 'follow') && event_hash['target']['screen_name'] && event_hash['created_at']
    end

    def is_status_event?(event_hash)
      event_hash['text'] && event_hash['user']['screen_name'] && event_hash['created_at'] 
    end

    def is_not_user_stream?
      !is_user_stream
    end

    def is_user_stream?
      is_user_stream
    end

    def valid_event?(event_hash)
      is_follow_event?(event_hash) || is_status_event?(event_hash)
    end
  end
end
