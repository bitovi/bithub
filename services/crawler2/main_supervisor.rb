class MainSupervisor
  include Celluloid

  def initialize
    @config = Configurator.new(ENV['ENV']).config
    boot
  end

  def boot
    @components = SupervisionGroup.new
    
    @components.supervise_as(:twitter_public_stream     , Streamers::Twitter::Filter    , *[twitter_auth])

    brands_config.each do |brand_name, cfg|
      Celluloid.logger.info "Booting #{brand_name}"
      @components.supervise_as(actor_name(brand_name), BrandSupervisor, *[brand_name, cfg])
    end
  end

  def restart_brand(brand_name)
    Celluloid::Actor[actor_name(brand_name)].terminate
    @brands.supervise_as(actor_name(brand_name), Streamer, *[brand_name, @config.fetch(brand_name)])
  end

  private

  def actor_name(brand_name)
    "#{brand_name}_supervisor".to_sym
  end

  def brands_config
    @config.fetch(:brands)
  end

  def twitter_auth
    @config.fetch(:public_streams).fetch(:twitter).fetch(:auth)
  end
end
