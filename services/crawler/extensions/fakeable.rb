module Fakeable
  FAKE_RESPONSES = File.expand_path(File.join(File.basename(__FILE__), '..', 'tmp', 'fake_responses'))

  def fetch(link = nil)
    remote = link || @endpoint
    local = resource_location(remote)

    if File.exists?(local) && File.readable?(local)
      puts "===> Local resource exists: #{local}"
      response = fetch_fake(local)
      handle_success(response)
    else
      puts "===> No local resource, fetching: #{remote}"
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
    # @logger.debug "URI: =========================> #{remote}"

    feed = determine_feed(remote)
    # @logger.debug "FEED: ========================> #{feed}"

    _, path_suffix = remote.match(/\.com(\/.*)*$/).to_a
    # @logger.debug "PATH_SUFFIX: ========================> #{path_suffix}"

    filename = feed.concat path_suffix.gsub(/\//, '_')
    File.join(FAKE_RESPONSES, filename)
  end

  def write_to_cache(response)
    f = File.new(resource_location(@endpoint), "w")
    f.write(response)
    f.close
  end
end
