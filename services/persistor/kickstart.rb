PERSISTOR_DIR = File.dirname(__FILE__)
ROOT_DIR = File.expand_path(File.join(File.basename(PERSISTOR_DIR), '..'))

$:.unshift(ROOT_DIR)
$:.unshift(File.join(ROOT_DIR, 'services'))
$:.unshift(File.join(ROOT_DIR, 'services', 'persistor'))
$:.unshift(File.join(ROOT_DIR, 'lib'))
$:.unshift(File.join(ROOT_DIR, 'app', 'models'))

# /
require 'services/intervals'
require 'config/environment'

# theirs
require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'

# /lib
require 'core_ext'
require 'core_helpers'
require 'logger_factory'

# Persistor
require 'persistor'

$env = ENV.fetch('ENV') { 'development' }
require 'pry' if $env == 'development'

logger = LoggerFactory.new('persistor', :environment => $env).logger
Celluloid.logger = logger

class Persistors < Celluloid::SupervisionGroup
  supervise(Persistor, as: :entity_persistor, args: [])
end

Persistors.run
