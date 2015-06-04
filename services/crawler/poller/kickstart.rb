POLLER_DIR  = File.dirname(__FILE__)
CRAWLER_DIR = File.expand_path(File.join(POLLER_DIR,  '..'))
ROOT_DIR    = File.expand_path(File.join(CRAWLER_DIR,  '..', '..'))

$:.unshift(POLLER_DIR)
$:.unshift(CRAWLER_DIR)
$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'lib'))
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))

# /
require 'services/intervals'

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

# /app/models
require 'events/dispatcher'

# /CRAWLER_DIR
require 'configuration_fetcher'
require 'command_handler'
require 'publishers/error_publisher'
require 'publishers/event_publisher'
require 'publishers/notification_publisher'
require 'supervisors/main'

# Poller
require 'poller'
require 'lock_manager'
require 'fetchers/all'
require 'persistent/digest_set'
require 'poller/services/all'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('crawler_poller', :environment => $env).logger
Celluloid.logger = logger

class Crawler < Celluloid::SupervisionGroup
  supervise EventPublisher,        as: :event_publisher
  supervise ErrorPublisher,        as: :error_publisher
  supervise NotificationPublisher, as: :notification_publisher
  supervise CommandHandler,        as: :commander, args: [{ consumer_name: 'poller' }]
  supervise ConfigurationFetcher,  as: :configurator
  supervise LockManager,           as: :lock_manager
  supervise Supervisors::Main,     as: :main
end

Crawler.run
