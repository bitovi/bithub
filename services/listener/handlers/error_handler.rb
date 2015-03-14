require 'handlers/handler'

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
