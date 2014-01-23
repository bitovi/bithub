require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))

require 'lib/core_ext'
require 'lib/core_helpers'

require 'events/processor'
require 'events/protocol'
