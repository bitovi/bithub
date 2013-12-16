require 'rspec'
require 'rspec/mocks'
require 'support/responses/response_loader'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))
require 'events/dispatcher'
