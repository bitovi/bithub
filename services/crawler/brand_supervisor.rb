require_relative 'feed_supervisors/all'

class BrandSupervisor
  include Celluloid

  def initialize(brand_name)
    @brand_name = brand_name
    boot
  end

  def boot
    @feeds = SupervisionGroup.new
    all_feed_configs.each do |feed_name, cfg|
      start_feed(feed_name)
    end
  end

  def reload_feed(feed_name)
    if Celluloid::Actor[actor_name(feed_name)].respond_to? :reload
      Celluloid.logger.info "Reloading #{actor_name(feed_name)}"
      Celluloid::Actor[actor_name(feed_name)].reload
    else
      stop_feed
      start_feed
    end
  end

  def start_feed(feed_name)
    Celluloid.logger.info "Starting #{actor_name(feed_name)}"
    @feeds.supervise_as(
      actor_name(feed_name),
      feed_supervisor(feed_name),
      *[@brand_name]
    )
  end

  def stop_feed(feed_name)
    Celluloid.logger.info "Stopping #{actor_name(feed_name)}"
    if (a = Celluloid::Actor[actor_name(feed_name)])
      a.terminate
    end
  end

  private

  def all_feed_configs
    Celluloid::Actor[:configurator].brand_config(@brand_name)
  end

  def actor_name(feed_name)
    "#{@brand_name}_#{feed_name}_supervisor".to_sym
  end

  def feed_supervisor(feed_name)
    const_name = feed_name.to_s.camel_case.to_sym
    FeedSupervisors.const_get(const_name)
  end

end
