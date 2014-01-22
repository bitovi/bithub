require 'entities/traits/determinable'
require 'entities/traits/groupable'
require 'entities/traits/normalizable'
require 'entities/traits/persistable'

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
    
    def find_by_origin_uid(uid)
      Entity.where("props -> 'origin_author_id' = ?", uid)
    end
  end
end
