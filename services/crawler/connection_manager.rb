require 'singleton'
require 'sequel'
require 'redis'
require 'bunny'

class ConnectionManager
  include Singleton

  def initialize
    @postgres = Sequel.connect(
      ENV.fetch('POSTGRES_URL'),
      :max_connections => 10,
      :logger => Celluloid.logger
    )

    @redis = Redis.new(:url => ENV.fetch('REDIS_URL'))
    @rabbit = Bunny.new((ENV.fetch('RABBITMQ_URI'))).start.create_channel
  end

  attr_reader :redis, :postgres, :rabbit
end
