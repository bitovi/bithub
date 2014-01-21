require 'tagger'
require 'lib/loggable'

module Entities
  class Determinator
    include Loggable

    def initialize(entity)
      initialize_logger
      @e = entity
    end

    def determine
      @e.determine_feed
      @e.determine_tags
      @e.determine_tags
      @e.determine_category
      @e.determine_rule
      @e.determine_author
    end

  end
end
