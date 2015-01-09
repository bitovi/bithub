require 'singleton'
require 'sequel'
require 'redis'

class ConnectionManager
  include Singleton
  def initialize
    @postgres = Sequel.connect(
      ENV.fetch('POSTGRES_URL'),
      :max_connections => 10,
      :logger => Celluloid.logger
    )

    @redis = Redis.new(:url => ENV.fetch('REDIS_URL'))
  end
  attr_reader :redis, :postgres
end
