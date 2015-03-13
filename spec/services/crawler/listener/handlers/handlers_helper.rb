$:.unshift File.join(PROJECT_ROOT, 'services')
$:.unshift File.join(PROJECT_ROOT, 'services', 'crawler')

require 'dotenv'
require 'spec_helper'
require 'core_ext'
require 'vcr'
require 'andand'

require 'celluloid/test'
require 'webmock/rspec'
require 'httparty'

require 'rabbit_factory'
require 'events/dispatcher'

require 'listener/http_server'
require 'listener/subscription_registry'
require 'listener/handlers/all'
require 'configuration_fetcher'
require 'connection_manager'
#require 'publishers/event_publisher'
require 'decorators/all'
require 'supervisors/owner_data'

Dotenv.load

# disable FB app subscription
ENV['INSIDE_TEST'] = 'true'

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

# Event publisher mock
class EventPublisherMock
  include Celluloid

  attr_reader :messages

  def initialize(opts={})
    @messages = []
  end

  def publish(events, owner_data)
    @messages << [events, owner_data]
  end
end

def build_postback_endpoint(path)
  port   = ENV['CRAWLER_HTTP_PORT'] || 3001
  prefix = ENV['CRAWLER_HTTP_PREFIX'] || '/api/postback/'

  File.join "http://127.0.0.1:#{port}", prefix, path
end

def load_response(path)
  File.new("spec/support/responses/#{path}").read.gsub(/\s+/, "")
end

# otherwise all net connects will fail
WebMock.allow_net_connect!
