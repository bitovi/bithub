class MainSupervisor
  include Celluloid

  def initialize
    boot
  end

  def boot
    @streams = SupervisionGroup.new
    @streams.supervise_as(
      :twitter_public_stream,
      Streamers::Twitter::Filter,
      *[twitter_auth]
    )

    @brands = SupervisionGroup.new
    all_brand_configs.each do |brand_name, cfg|
      Celluloid.logger.info "Booting brand: #{brand_name}"
      start_brand(brand_name)
    end
  end

  def reload_brand_feed(brand_name, feed_name)
    if Celluloid::Actor[actor_name(brand_name)].respond_to? :reload_feed
      Celluloid.logger.info "Reloading #{actor_name(brand_name)}"
      Celluloid::Actor[actor_name(brand_name)].reload_feed(feed_name)
    else
      stop_brand(brand_name)
      start_brand(brand_name)
    end
  end

  def start_brand(brand_name)
    Celluloid.logger.info "Starting #{actor_name(brand_name)}"
    @brands.supervise_as(
      actor_name(brand_name),
      BrandSupervisor,
      *[brand_name]
    )
  end

  def stop_brand(brand_name)
    Celluloid.logger.info "Stopping #{actor_name(brand_name)}"
    Celluloid::Actor[actor_name(brand_name)].terminate
  end

  private
  
  def all_brand_configs
    Celluloid::Actor[:configurator].whole_config
  end

  def actor_name(brand_name)
    "#{brand_name}_supervisor".to_sym
  end

  def twitter_auth
    config = Celluloid::Actor[:configurator].static_config
    if config
      config.fetch(:public_streams).fetch(:twitter)
    else
      [:error, "unable to provide local config"]
    end
  end
end
