LISTENER_DIR  = File.dirname(__FILE__)
CRAWLER_DIR = File.expand_path(File.join(LISTENER_DIR,  '..'))
ROOT_DIR    = File.expand_path(File.join(CRAWLER_DIR,  '..', '..'))

$:.unshift(LISTENER_DIR)
$:.unshift(CRAWLER_DIR)
$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'lib'))
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))

# theirs
require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'

# /lib
require 'core_ext'
require 'core_helpers'
require 'rabbit_helper'
require 'logger_factory'

# /CRAWLER_DIR
require 'configuration_fetcher'
require 'command_handler'
require 'publishers/error_publisher'
require 'publishers/event_publisher'
require 'publishers/notification_publisher'
require 'decorators/all'
require 'supervisors/main'

# Streamer
require 'lock_manager'
require 'channel'
require 'registrator'
require 'connectors/all'
require 'stream_supervisor'
require 'streamer/services/all'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('crawler_streamer', :environment => $env).component_logger
Celluloid.logger = logger

class Streamer < Celluloid::SupervisionGroup
  supervise EventPublisher,       as: :publisher
  supervise Registrator,          as: :registrator
  supervise ConfigurationFetcher, as: :configurator
  supervise LockManager,          as: :lock_manager
  supervise StreamSupervisor,     as: :stream_supervisor
end

Streamer.run
