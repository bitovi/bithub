require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))

require 'lib/core_ext'
require 'lib/core_helpers'

require 'app/domain/events/processor'
require 'app/domain/events/protocol'

require 'app/domain/entities/protocol'

require 'app/domain/queries/query'
require 'app/domain/queries/query_item'

require 'app/domain/digest_queue'
require 'app/domain/tagger'
require 'app/domain/dispatcher'
