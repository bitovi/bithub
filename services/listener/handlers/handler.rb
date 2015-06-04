class Handler

  def initialize(listener)
    @listener = listener
  end

  def handle
    fail NotImplementedError
  end

  def meta_to_log_format(packet)
    m = packet.fetch 'meta'
    "#{m['brand_id']},#{m['embed_id']},#{m['service_id']},#{m['feed_name']},#{m['type_name']}"
  end

end
