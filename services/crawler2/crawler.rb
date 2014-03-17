RootDir = File.expand_path(File.join(File.dirname(__FILE__),  '..', '..'))

$:.unshift(File.join(RootDir, 'app', 'domain'))
$:.unshift(File.join(RootDir, 'lib'))
$:.unshift(File.join(RootDir, 'services'))

require 'bundler/setup'
require 'rubygems'
require 'celluloid'
require 'bunny'

require 'core_ext'
require 'logger_factory'

require_relative 'publisher'
require_relative 'generic_producer'
require_relative 'feed_supervisor'

# log4r logger
logger = LoggerFactory.new('crawler', ENV['ENV']).component_logger

Celluloid.logger = logger

class Crawler < Celluloid::SupervisionGroup
  supervise Publisher, as: :Publisher
  supervise GenericProducer, as: :GenericProducer
  supervise FeedSupervisor, as: :TwitterSupervisor, args: [:twitter]
  supervise FeedSupervisor, as: :MeetupSupervisor, args: [:meetup]
end

Crawler.run
