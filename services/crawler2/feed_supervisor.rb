require_relative 'configurator'
require_relative 'poller'
require_relative 'streamer'

class FeedSupervisor
  include Celluloid

  def initialize(feed_name)
    p(feed_name: feed_name)

    @config = Configurator.new(ENV['ENV']).config(feed_name)
    boot
  end

  def boot
    endpoints_supervisor = SupervisionGroup.new

    polling_endpoints.each do |name, cfg|
      endpoints_supervisor.supervise_as name, Poller, *[cfg[:url], cfg[:interval]]
    end
  end

  private

  def polling_endpoints
    @config[:polling]
  end

  def streaming_endpoints
    @config[:streaming]
  end

end
