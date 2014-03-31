require_relative 'feed_supervisors/all'

class BrandSupervisor
  include Celluloid

  def initialize(brand_name, cfg)
    @brand_name = brand_name
    @config = cfg
    boot
  end

  def boot
    @feeds = SupervisionGroup.new

    feeds_config.each do |feed_name, cfg|
      @feeds.supervise_as(actor_name(feed_name), feed_supervisor(feed_name), *[@brand_name, cfg])
    end
  end

  def restart_feed(feed_name)
    Celluloid::Actor[actor_name(feed_name)].terminate
    @feeds.supervise_as(actor_name(feed_name), feed_supervisor(feed_name), *[@brand_name, @config.fetch(feed_name)])
  end


  private
  
  def actor_name(feed_name)
    "#{@brand_name}_#{feed_name}_supervisor".to_sym
  end

  def feeds_config
    @config
  end

  def feed_supervisor(feed_name)
    const_name = feed_name.to_s.camel_case.to_sym
    FeedSupervisors.const_get(const_name)
  end
  
end
