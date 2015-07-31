LISTENER_DIR = File.dirname(__FILE__)
ROOT_DIR = File.expand_path(File.join(LISTENER_DIR, '..', '..'))

$:.unshift(LISTENER_DIR)
$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))
$:.unshift(File.join(ROOT_DIR, 'lib'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'

# /
require 'config/environment'
require 'services/intervals'

# /lib
require 'core_ext'
require 'rabbit_helper'
require 'logger_factory'
require 'connection_manager'

# /app/models
require 'events/events'

# /LISTENER_DIR
require 'persistor'

# /LISTENER_DIR
require 'updater'
require 'listener'
require 'handlers/error_handler'
require 'handlers/command_handler'
require 'handlers/event_handler'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('listener', :environment => $env).logger
Celluloid.logger = logger

class WebWorkers < Celluloid::SupervisionGroup
  supervise(Updater, as: :entity_updater, args: [])
  supervise(Persistor, as: :entity_persistor, args: ['q.web.entities', 'entities'])
  supervise(Listener, as: :error_listener, args: ['q.web.errors', 'errors', ErrorHandler])
  supervise(Listener, as: :event_listener, args: ['q.web.events', 'events', EventHandler])
  supervise(Listener, as: :command_listener, args: ['q.web.commands', 'commands', CommandHandler])
end

WebWorkers.run
