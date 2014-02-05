require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))

def make_dummy_event(i)
  Hash.new({content_digest: Digest::MD5.hexdigest(i.to_s), data: {title: "Event #{i}"}})
end

require 'core_ext'
require 'core_helpers'

require 'events/processor'
require 'events/protocol'
