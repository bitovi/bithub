class StreamSupervisor
  include Celluloid

  def initialize
    @streams = SupervisionGroup.new
    boot
  end

  def boot
    boot_twitter
  end

  def boot_twitter
    @streams.supervise_as(
      :twitter_public_stream,
      Streamers::Twitter::Filter,
      *[]
    )

    all_brand_configs.each do |brand_name, cfg|
      cfg = twitter_config(brand_name)
      twitter_stream.register Channel.new(brand_name, cfg[:terms])
    end
  end

  def boot_meetup
  end

  def all_brand_configs
    Celluloid::Actor[:configurator].all_brands
  end
    
  def twitter_config(brand_name)
    Celluloid::Actor[:configurator].feed_config(brand_name, :twitter)
  end

  def twitter_stream
    Celluloid::Actor[:twitter_public_stream]
  end

  def locker
    Celluloid::Actor[:lock_manager]
  end

  def twitter_lock_name
    'lock:streaming:twitter'
  end

  def meetup_lock_name
    'lock:streaming:meetup'
  end
  
  def twitter_lock_duration
    300
  end
  
  def meetup_lock_duration
    15
  end

end
