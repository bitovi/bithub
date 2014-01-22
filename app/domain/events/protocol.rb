require_relative 'traits/constructable'
require_relative 'traits/persistable'
require_relative 'traits/comparable'
require_relative 'traits/digestable'

module Events
  class InitializationError < Exception; end
  class BuildingError < Exception; end
  class MappingError < Exception; end

  class Protocol

    include Constructable
    include Persistable
    include Comparable
    include Digestable

    def initialize(payload)
      @data = symbolize_keys(payload)
    end

    def source_data
      @data
    end
  end
end
