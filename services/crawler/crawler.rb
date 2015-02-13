CRAWLER_DIR = File.dirname(__FILE__)
ROOT_DIR = File.expand_path(File.join(CRAWLER_DIR,  '..', '..'))

$:.unshift(CRAWLER_DIR)
$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))
$:.unshift(File.join(ROOT_DIR, 'lib'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'

# /lib
require 'core_ext'
require 'core_helpers'
require 'rabbit_factory'
require 'logger_factory'

# /app/models
require 'events/dispatcher'

# /CRAWLER_DIR
require_relative 'supervisors/main'
require_relative 'lock_manager'
require_relative 'publishers/error_publisher'
require_relative 'publishers/event_publisher'
require_relative 'publishers/notification_publisher'
require_relative 'configurator'
require_relative 'commander'
require_relative 'poller'
require_relative 'decorators/all'
require_relative 'persistent/digest_set'
require_relative 'response_processor'
require_relative 'http_server/listener'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('crawler', :environment => $env).component_logger
Celluloid.logger = logger

class Crawler < Celluloid::SupervisionGroup
  supervise EventPublisher, as: :event_publisher
  supervise ErrorPublisher, as: :error_publisher
  supervise NotificationPublisher, as: :notification_publisher
  supervise Commander, as: :commander
  supervise Configurator, as: :configurator
  supervise LockManager, as: :lock_manager
  supervise Supervisors::Main, as: :main
  supervise HttpServer::Listener, as: :http_listener
end

Crawler.run
