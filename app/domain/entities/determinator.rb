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
      begin
        @e.determine_feed
        @e.determine_tags
        @e.determine_tags
        @e.determine_category
        @e.determine_rule
        @e.determine_author
      rescue NoMethodError => e
        puts "--- GLUPOST"
        puts "=========================================> #{@e.class.name}"
        puts "=========================================> #{@e.instance}"
      end

    end

  end
end
