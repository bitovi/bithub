require_relative 'traits/constructable'
require_relative 'traits/persistable'
require_relative 'traits/comparable'
require_relative 'traits/digestable'

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
