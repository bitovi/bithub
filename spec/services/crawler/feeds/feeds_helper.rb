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
require 'amqp_helpers'

require 'events/dispatcher'

require 'listener/http_server'
require 'publisher'
require 'configurator'
require 'decorators/all'
require 'supervisors/support/owner_data'

# conn params for services like rabbitmq
Dotenv.load

# first time saves the responses to be used later
VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.ignore_localhost = true
end

# otherwise all net connects will fail
WebMock.allow_net_connect!
