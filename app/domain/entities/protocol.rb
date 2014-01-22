module Entities
  class Protocol
    class DeterminationError < Exception; end
    class NormalizationError < Exception; end
    class BuildingError < Exception; end
    class GroupingError < Exception; end

    include Constructable
    include Determinable
    include Groupable
    include Normalizable
    include Persistable
    
    attr_reader :instance

    def initialize(payload)
      @payload = payload
    end
  end
end
