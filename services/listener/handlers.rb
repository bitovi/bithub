class Handler
  def initialize(listener)
    @listener = listener
  end

  def handle
    fail NotImplementedError
  end
end

class ErrorHandler < Handler
  def handle(packet)
    bn, en, err, err_klass = destruct(packet)
    Celluloid.logger.info "New ERROR received: #{err_klass}; brand: '#{bn}', embed: '#{en}'"

    @listener.handle_errors do
      Apartment::Tenant.switch(bn) do
        ServiceError.new(err).save!
      end
    end
  end

  def destruct(packet) 
    meta = packet.fetch('meta')
    err =  packet.fetch('error')
    [ meta.fetch('brand_name'), meta.fetch('embed_name'), err, err.fetch('klass') ]
  end
end

class EventHandler < Handler
  def handle(packet)
    bn, en, fn, tn = destruct(packet)
    Celluloid.logger.info "New EVENT received: '#{fn}/#{tn}', brand: '#{bn}', embed: '#{en}'"

    @listener.handle_errors do
      Apartment::Tenant.switch(bn) do
        Dispatcher.new(logger: Celluloid.logger).dispatch(packet)
      end
    end
  end

  def destruct(packet)
    meta = packet.fetch('meta')
    [ meta.fetch('brand_name'), meta.fetch('embed_name'), meta.fetch('feed_name'), meta.fetch('type_name') ]
  end
end

class CommandHandler < Handler
  def handle(packet)
    bn, sid = destruct(packet)
    Celluloid.logger.info "New COMMAND received: #{packet.fetch('payload')}, brand: '#{bn}'"

    @listener.handle_errors do
      Apartment::Tenant.switch(bn) do
        ServiceError.where(service_id: sid).destroy_all
      end
    end
  end

  def destruct(packet)
    [ packet.fetch('meta').fetch('brand_name'), packet.fetch('payload').fetch('service').fetch('id') ]
  end
end
