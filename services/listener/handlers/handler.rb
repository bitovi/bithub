class Handler

  def initialize(listener)
    @listener = listener
  end

  def handle
    fail NotImplementedError
  end

  def meta_to_log_format(packet)
    m = packet.fetch 'meta'
    "[#{m['brand_name']} #{m['embed_name']} #{m['service_id']} #{m['feed_name']} #{m['type_name']}]"
  end

end
