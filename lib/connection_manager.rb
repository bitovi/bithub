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

  def shared_rabbit
    @rabbit_chan ||= @rabbit_conn.create_channel
  end
  alias_method :shared_rabbitmq, :shared_rabbit

  def redis
    @redis_conn
  end
end
