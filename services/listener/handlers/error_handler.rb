require 'handlers/handler'

class ErrorHandler < Handler
  def handle(packet)
    b_id, err, err_klass = destruct(packet)
    Celluloid.logger.info "[#{meta_to_log_format(packet)}][ERROR_LISTENER] New error received: #{err_klass}"

    @listener.handle_errors do
      Apartment::Tenant.switch(Brand.find(b_id).name) do
        ServiceError.new(err).save!
      end
    end
  end

  def destruct(packet)
    meta = packet.fetch('meta')
    err =  packet.fetch('error')
    [ meta.fetch('brand_id'), err, err.fetch('klass') ]
  end
end
