require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))

require 'yaml'
require 'core_ext'
require 'core_helpers'
