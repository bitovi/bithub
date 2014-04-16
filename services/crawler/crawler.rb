#!/usr/bin/env ruby
RootDir = File.expand_path(File.join(File.dirname(__FILE__),  '..', '..'))

$:.unshift(File.join(RootDir, 'app'))
$:.unshift(File.join(RootDir, 'app', 'domain'))
$:.unshift(File.join(RootDir, 'lib'))
$:.unshift(File.join(RootDir, 'services'))

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

require_relative 'main_supervisor'
require_relative 'brand_supervisor'
require_relative 'publisher'
require_relative 'configurator'
require_relative 'commander'
require_relative 'poller'
require_relative 'channel'
require_relative 'streamers/all'
require_relative 'fetchers/all'
require_relative 'http_server/listener'
require_relative 'digest_set'
require_relative 'response_processor'

# log4r logger
$env = ENV.fetch('ENV')
logger = LoggerFactory.new('crawler', $env).component_logger

Celluloid.logger = logger

class Crawler < Celluloid::SupervisionGroup
  supervise Publisher, as: :publisher
  supervise Commander, as: :commander
  supervise Configurator, as: :configurator, args: [{environment: $env}]
  supervise HttpServer::Listener, as: :http_listener
  supervise MainSupervisor, as: :main_supervisor
end

Crawler.run
