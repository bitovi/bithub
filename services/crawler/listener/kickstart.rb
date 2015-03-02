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
require 'rabbit_factory'
require 'logger_factory'

# /app/models
require 'events/dispatcher'

# /CRAWLER_DIR
require 'configuration_fetcher'
require 'command_handler'
require 'publishers/error_publisher'
require 'publishers/event_publisher'
require 'publishers/notification_publisher'
require 'decorators/all'
require 'supervisors/main'

# Listener
require 'http_server'
require 'subscription_registry'
require 'fetchers/all'
require 'handlers/all'
require 'listener/services/all'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('crawler_listener', :environment => $env).component_logger
Celluloid.logger = logger

class Listener < Celluloid::SupervisionGroup
  supervise SubscriptionRegistry, as: :subscription_registry
  supervise ConfigurationFetcher, as: :configurator
  supervise CommandHandler,       as: :commander, args: [:main]
  supervise EventPublisher,       as: :event_publisher
  supervise ErrorPublisher,       as: :error_publisher
  supervise HttpServer,           as: :http_server, args: [{host: '0.0.0.0'}]
  supervise Supervisors::Main,    as: :main
end

Listener.run
