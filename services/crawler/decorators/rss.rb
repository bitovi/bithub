module Decorators
  class Rss < Protocol

    def initialize(site_config)
      @url = site_config[:url]
      @name = site_config[:name]
    end

    def decorate(event)
      event[:meta][:source_url] = @url
      event
    end
  end
end
