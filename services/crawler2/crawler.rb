RootDir = File.expand_path(File.join(File.dirname(__FILE__),  '..', '..'))

$:.unshift(File.join(RootDir, 'app', 'domain'))
$:.unshift(File.join(RootDir, 'lib'))
$:.unshift(File.join(RootDir, 'services'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'celluloid/io'
require 'bunny'
require 'redis'

require 'core_ext'
require 'logger_factory'

require_relative 'main_supervisor'
require_relative 'brand_supervisor'
require_relative 'publisher'
require_relative 'configurator'
require_relative 'poller'
require_relative 'streamers/all'
require_relative 'fetchers/all'

# log4r logger
logger = LoggerFactory.new('crawler', ENV['ENV']).component_logger

$app_auth = {
  twitter: {
    api_key: 'huCmG0TZ7vs6leLqLNlGQ',
    api_secret: 'X4mx1qgGlZ1BVIFFUDB4kzrE1NV7t0nAjx5hY5tQOWQ'
  },
  meetup: {
    api_key: '663a24605a37767831495d6332546b4a'
  }
}

Celluloid.logger = logger

class Crawler < Celluloid::SupervisionGroup
  supervise Publisher, as: :Publisher
  supervise MainSupervisor, as: :MainSupervisor
end

Crawler.run
