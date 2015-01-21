ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__),  '..', '..'))

$:.unshift(File.join(ROOT_DIR, 'app'))
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))
$:.unshift(File.join(ROOT_DIR, 'lib'))
$:.unshift(File.join(ROOT_DIR, 'services'))
$:.unshift(File.join(ROOT_DIR, 'services', 'crawler'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'
require 'bunny'
require 'pry'
require 'core_ext'
require 'core_helpers'
require 'rabbit_factory'
require 'logger_factory'

require 'events/dispatcher'

require_relative 'supervisors/main'
require_relative 'lock_manager'
require_relative 'publishers/error'
require_relative 'publishers/event'
require_relative 'configurator'
require_relative 'commander'
require_relative 'poller'
require_relative 'decorators/all'
require_relative 'persistent/digest_set'
require_relative 'response_processor'
require_relative 'http_server/listener'

# log4r logger
$env = ENV.fetch('ENV') { 'development' }
logger = LoggerFactory.new('crawler', :environment => $env).component_logger

Celluloid.logger = logger

class Crawler < Celluloid::SupervisionGroup
  supervise EventPublisher, as: :event_publisher
  supervise ErrorPublisher, as: :error_publisher
  supervise Commander, as: :commander
  supervise Configurator, as: :configurator, args: [{environment: $env}]
  supervise LockManager, as: :lock_manager
  supervise HttpServer::Listener, as: :http_listener
  supervise Supervisors::Main, as: :main
end

Crawler.run
