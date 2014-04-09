class MainSupervisor
  include Celluloid
  include CoreHelpers

  def initialize
    @configurator = Configurator.new(ENV['ENV'])
    boot
  end

  def boot
    @components = SupervisionGroup.new
    @components.supervise_as(
      :twitter_public_stream,
      Streamers::Twitter::Filter,
      *[twitter_auth]
    )

    all_brand_configs.each do |brand_name, cfg|
      Celluloid.logger.info "Booting #{brand_name}"
      @components.supervise_as(
        actor_name(brand_name),
        BrandSupervisor,
        *[brand_name, cfg]
      )
    end
  end

  def restart_brand(brand_name)
    Celluloid.logger.info "Restarting brand: #{brand_name}"
    Celluloid::Actor[actor_name(brand_name)].terminate
    @brands.supervise_as(
      actor_name(brand_name),
      Streamer,
      *[brand_name, @configurator.brand_config(brand_name)]
    )
  end

  private

  def actor_name(brand_name)
    "#{brand_name}_supervisor".to_sym
  end

  def all_brand_configs
    @configurator.whole_config
  end

  def twitter_auth
    @configurator.static_config
    .fetch(:public_streams)
    .fetch(:twitter)
    .fetch(:auth)
  end
end
