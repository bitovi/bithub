require 'spec_helper'
require 'guzzler/guzzler'

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/1'
REDIS = Guzzler::RedisConnection.create(:url => REDIS_URL, :namespace => 'testy')
Guzzler.redis = REDIS
