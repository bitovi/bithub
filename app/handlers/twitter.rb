module Handler
  class Twitter
    def self.handle_event(exchange, raw_json)
      event = Yajl::Parser.parse(raw_json)

      hash = {
        actor: event['user']['screen_name'],
        feed: 'twitter',
        timestamp: Time.strptime(event['created_at'], "%a %b %m %T %z %Y").strftime("%FT%T%z"),
        link: event['source'],
        title: event['text'],
        hash_key: Digest::MD5.hexdigest(event['id'].to_s+'twitter')
      }

      enqueue_events = proc do
        exchange.publish(Yajl::Encoder.encode(hash), routing_key: "tasks.taggify")
      end

      # Sending (network IO) in a separate lightweight process
      # so that the reactor loop can continue
      EM.defer(enqueue_events)
    end
  end
end
