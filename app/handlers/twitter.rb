module Handler
  class Twitter
    def self.handle_event(log, exchange, raw_json)
      event = Yajl::Parser.parse(raw_json)
      parsed_date = Time.strptime(event['created_at'], "%a %b %d %T %z %Y")

      hash = {
        actor: event['user']['screen_name'],
        feed: 'twitter',
        timestamp: parsed_date.strftime("%FT%T%z"),
        link: event['source'],
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
end
