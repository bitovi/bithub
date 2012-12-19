module Handler
  class Twitter
    def self.handle_site_stream_event(log, exchange, raw_json)
      event = Yajl::Parser.parse(raw_json)

      if event['created_at'] && event['user']
        if event['created_at']
          parsed_date = Time.strptime(event['created_at'], "%a %b %d %T %z %Y")
        else
          parsed_date = Time.now
        end

        hash = {
          actor: event['user']['screen_name'],
          actor_id: event['user']['id_str'],
          feed: 'twitter',
          timestamp: parsed_date.strftime("%FT%T%z"),
          link: "https://twitter.com/#{event['user']['screen_name']}/status/#{event['id_str']}",
          title: event['text'],
          hash_key: Digest::MD5.hexdigest(event['id_str']+'twitter')
        }

        enqueue_events = proc do
          exchange.publish(Yajl::Encoder.encode(hash), routing_key: "tasks.taggify")
        end

        # Sending (network IO) in a separate lightweight process
        # so that the reactor loop can continue

        EM.defer(enqueue_events)
      end
    end

    def self.handle_user_stream_event(log, exchange, raw_json)
      event = Yajl::Parser.parse(raw_json)

      if (event['created_at'] && 
          event['event'] == 'follow' &&
          event['target']['screen_name'] == 'canjs')

        parsed_date = Time.strptime(event['created_at'], "%a %b %d %T %z %Y")

        hash = {
          actor: event['source']['screen_name'],
          actor_id: event['source']['id'],
          feed: 'twitter',
          type: 'follow_event',
          timestamp: parsed_date.strftime("%FT%T%z"),
          title: "followed @canjs"
        }

        enqueue_events = proc do
          exchange.publish(Yajl::Encoder.encode(hash), routing_key: "tasks.taggify")
        end

        EM.defer(enqueue_events)
      end
    end

  end
end
