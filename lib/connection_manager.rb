require 'singleton'
require 'redis'
require 'bunny'

class ConnectionManager
  include Singleton

  def initialize
    @redis_conn = Redis.new(:url => ENV.fetch('REDIS_URL'))
    @rabbit_conn = Bunny.new((ENV.fetch('RABBITMQ_URI'))).start
  end

  def rabbit
    @rabbit_conn.create_channel
  end
  alias_method :rabbitmq, :rabbit

  def short_lived_rabbit
    chan = @rabbit_conn.create_channel
    yield chan
    chan.close
  end
  alias_method :short_lived_rabbitmq, :short_lived_rabbit

  def redis
    @redis_conn
  end
end
