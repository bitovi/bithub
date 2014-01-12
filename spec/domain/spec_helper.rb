require 'spec_helper'

# Domain logic is in app/domain
$:.unshift(File.expand_path(File.join('app', 'domain')))

require 'app/domain/events/payload'
require 'app/domain/events/processor'

require 'app/domain/entities/grouper'
require 'app/domain/entities/determinator'
require 'app/domain/entities/normalizer'
require 'app/domain/entities/procurer'

require 'app/domain/queries/query_logic_analyzer'
require 'app/domain/queries/scope_applier'

require 'app/domain/digest_queue'
require 'app/domain/tagger'
require 'app/domain/dispatcher'
