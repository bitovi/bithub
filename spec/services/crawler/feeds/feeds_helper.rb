$:.unshift File.join(PROJECT_ROOT, 'services')
$:.unshift File.join(PROJECT_ROOT, 'services', 'crawler')

require 'dotenv'
require 'spec_helper'
require 'core_ext'

require 'celluloid/test'
require 'webmock/rspec'
require 'httparty'
require 'amqp'
require 'amqp_helpers'

require 'events/dispatcher'

require 'http_server/listener'
require 'publisher'
require 'decorators/all'

# conn params for services like rabbitmq
Dotenv.load
