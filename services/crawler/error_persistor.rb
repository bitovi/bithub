require 'connection_manager'

class ErrorPersistor
  include Celluloid

  def initialize(error, service_id)
    @error = error
    @service_id = service_id

    @postgres = ConnectionManager.instance.postgres
    @service_errors = @postgres[:service_errors]
  end
  attr_reader :error, :errors_table

  def persist(brand_name = 'default')
    @postgres.execute("SET search_path TO #{brand_name}")
    @service_errors.insert(
      :klass => @error.class.name,
      :message => @error.message,
      :service_id => @service_id
    )
    @postgres.execute('SET search_path TO default')
  end

  def errors
    @service_errors
  end
end
