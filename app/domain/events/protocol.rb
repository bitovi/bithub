require 'events/modules/constructable'
require 'events/modules/persistable'
require 'events/modules/comparable'
require 'events/modules/digestable'

module Events
  class Protocol
    class InitializationError < Exception; end
    class BuildingError < Exception; end
    class MappingError < Exception; end

    include Constructable
    include Persistable
    include Comparable
    include Digestable

    def initialize(payload)
      @data = payload
    end
    
    def source_data
      @data
    end
  end
end
