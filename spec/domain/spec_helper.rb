require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))
require 'app/domain/events/payload'
require 'app/domain/events/processor'
