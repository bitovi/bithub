PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift PROJECT_ROOT

require 'rspec'
require 'rspec/mocks'
require 'webmock/rspec'
require 'vcr'

require 'celluloid'
require 'celluloid/io'

require 'lib/core_helpers'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end

Celluloid.logger.level = Logger::ERROR
