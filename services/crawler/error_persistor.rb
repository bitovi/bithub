require 'connection_manager'
require 'amqp_helpers'

class LiveserviceNotifier
  include AmqpHelpers

  def notif(msg, rk)
    rabbit(exchange_name: 'x.liveservice', exchange_opts: {auto_delete: true}).publish(msg, rk)
  end
end

class ErrorPersistor
  include Celluloid

  def initialize(error, owner_info)
    @error = error
    @brand_name = owner_info.brand.name
    @embed_id = owner_info.embed.id
    @service_id = owner_info.service.id

    @postgres = ConnectionManager.instance.postgres
    @service_errors = @postgres[:service_errors]
  end
  attr_reader :error, :errors_table

  # TODO stavit u transakciju
  def persist(brand_name = 'default')
    @postgres.execute("SET search_path TO #{@brand_name}")
    @service_errors.insert(
      :klass => @error.class.name,
      :message => @error.message,
      :service_id => @service_id
    )
    @postgres.execute('SET search_path TO default')
    self
  end

  def notify_client
    LiveserviceNotifier.new.notif({
      meta: {
        brand_name: @brand_name,
        embed_id: @embed_id
      },
      payload: {
        service: { id: @service_id }
      }
    }, :services)
  end

  def errors
    @service_errors
  end
end
