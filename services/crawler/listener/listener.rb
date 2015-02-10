ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__),  '..', '..', '..'))

$:.unshift(File.join(ROOT_DIR, 'lib'))
$:.unshift(File.join(ROOT_DIR, 'services', 'crawler'))
$:.unshift(File.join(ROOT_DIR, 'services', 'crawler', 'supervisors', 'support'))

# theirs
require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'
require 'bunny'
require 'pry'

# ours
require 'core_ext'
require 'core_helpers'
require 'amqp_helpers'
require 'logger_factory'
require 'configurator'
require 'publisher'

# listener
require_relative 'http_server'
require_relative 'handlers/all'

$env    = ENV.fetch('ENV') { 'development' } # used in configurator.rb, remove and update tests
$logger = LoggerFactory.new('crawler', :environment => $env).component_logger

class Listener < Celluloid::SupervisionGroup
  configurator_actor_name = :configurator
  publisher_actor_name    = :publisher
  http_server_actor_name  = :http_server

  supervise Configurator, as: configurator_actor_name, args: [{environment: $env}]
  supervise Publisher,    as: publisher_actor_name
  supervise HttpServer,   as: http_server_actor_name, args: [{
    host: '0.0.0.0',
    publisher_name: publisher_actor_name,
    logger: $logger,
    configurator_name: configurator_actor_name
  }]
end

Listener.run
