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

  def redis
    @redis_conn
  end
end
