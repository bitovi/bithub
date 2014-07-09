class StreamSupervisor
  include Celluloid

  def initialize
    boot
  end

  def boot
    @streams = SupervisionGroup.new

    Celluloid.logger.info "Booting Twitter stream"
    @streams.supervise_as(
      :twitter_public_stream,
      Streamers::Twitter::Filter,
      *[]
    )
  end

end
