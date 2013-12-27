module Fetchers
  module Fake
    FAKE_RESPONSES = File.expand_path(File.join(File.basename(__FILE__), '..', 'tmp', 'fake_responses'))
    puts "===> Dev mode, responses cached and read from #{FAKE_RESPONSES}"

    def fetch(link = nil)
      remote = link || @endpoint
      local = resource_location(remote)

      if File.exists?(local) && File.readable?(local)
        puts "===> Local resource exists: #{local}"
        response = fetch_fake(local)
        handle_success(response)
      else
        fetch_real(remote) do |r|
          write_to_cache(r)
          handle_success(r)
        end
      end
    end

    def fetch_fake(loc)
      File.read(loc)
    end

    def fetch_real(uri)
      http_req = EM::HttpRequest.new(uri).get({
        query: http_query,
        head: http_head
      })

      http_req.callback do
        if success?(http_req)
          yield(http_req.response) if block_given?
        else
          log_http_status(http_req, :error)
        end
      end

      http_req.errback do
        log_http_status(http_req, :error)
      end
    end

    def resource_location(remote)
      @feed = determine_feed(remote)
      File.join(FAKE_RESPONSES, @feed + '.json')
    end

    def write_to_cache(response)
      f = File.new(resource_location(@endpoint), "w")
      f.write(response)
      f.close
    end
  end

  module HTTP
    def fetch(link = nil)
      link = link || @endpoint

      http_req = EM::HttpRequest.new(link).get({
        query: http_query,
        head: http_head
      })

      http_req.callback do
        if success?(http_req)
          delay(1, lambda {fetch_next_page http_req}) if in_github_issues?
          handle_success(http_req)
        elsif client_error?(http_req)
          log_http_status(http_req, :error)
        elsif server_error?(http_req)
          log_http_status(http_req, :warn)
        else
          log_http_status(http_req, :error)
        end
      end

      http_req.errback do
        log_http_status(http_req, :error)
      end
    end
  end
end
