module Handler
  class Github < Base

    # TODO
    # def bootstrap
    # end

    def fetch
      org_events = EventMachine::HttpRequest.new('https://api.github.com/orgs/jupiterjs/events').get


      org_events.callback do
        github_events = Yajl::Parser.parse(org_events.response)

        ids = github_events.collect {|e| e['id']}
        new_events = github_events.reject {|e| @latest.include? e['id']}
        @latest = ids

        events = new_events.collect do |event|
          { raw_data: Base64::encode64(Yajl::Encoder.encode(event)),
            feed: 'github',
            type: event['type'],
            timestamp: event['created_at'],
            username: event['actor']['login']
          }
        end

        if new_events.size > 0
          @log.info "#{feed}: #{events.size} new events"
          store(events)
        else
          @log.info "#{feed}: Nothing new"
        end
      end

      org_events.errback do
        @log.error "Error: #{org_events.response_header.status}, header: #{org_events.response_header}, response: #{org_events.response}"
      end
    end
  end
end


# if new_events.size >= 25
#   EM.add_timer(1.5, &github)
# end
