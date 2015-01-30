$:.unshift File.join(PROJECT_ROOT, 'services')
$:.unshift File.join(PROJECT_ROOT, 'services', 'crawler')

require 'dotenv'
require 'spec_helper'
require 'core_ext'
require 'vcr'

require 'celluloid/test'
require 'webmock/rspec'
require 'httparty'
require 'amqp'

require 'rabbit_factory'
require 'events/dispatcher'

require 'connection_manager'
require 'http_server/listener'
require 'publishers/event_publisher'
require 'decorators/all'

Dotenv.load

RSpec.configure do |config|

  config.before(:suite) do
    $rabbit_channel = ConnectionManager.instance.rabbit
  end

  config.after(:suite) do
    $rabbit_channel.close
  end
end

# first time saves the responses to be used later
VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
end

# otherwise all net connects will fail
WebMock.allow_net_connect!
