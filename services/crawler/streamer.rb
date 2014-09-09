#!/usr/bin/env ruby
RootDir = File.expand_path(File.join(File.dirname(__FILE__),  '..', '..'))

$:.unshift(File.join(RootDir, 'app'))
$:.unshift(File.join(RootDir, 'app', 'domain'))
$:.unshift(File.join(RootDir, 'lib'))
$:.unshift(File.join(RootDir, 'services'))
$:.unshift(File.join(RootDir, 'services', 'crawler'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'
require 'bunny'
require 'redis'

require 'pry'
require 'core_ext'
require 'core_helpers'
require 'amqp_helpers'
require 'logger_factory'

require 'events/dispatcher'

require_relative 'configurator'
require_relative 'lock_manager'
require_relative 'publisher'
require_relative 'streamer/channel'
require_relative 'streamer/registrator'
require_relative 'streamer/connectors/all'
require_relative 'streamer/stream_supervisor'
require_relative 'decorators/all'
require_relative 'http_server/listener'
require_relative 'response_processor'

$env = ENV.fetch('ENV') { 'development' }
logger = LoggerFactory.new('crawler', :environment => $env).component_logger

class Streamer < Celluloid::SupervisionGroup
  supervise Publisher, as: :publisher
  supervise Registrator, as: :registrator
  supervise Configurator, as: :configurator, args: [{environment: $env}]
  supervise LockManager, as: :lock_manager
  supervise HttpServer::Listener, as: :http_listener
  supervise StreamSupervisor, as: :stream_supervisor
end

Streamer.run
