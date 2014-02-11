module Events
  class BaseError < Exception
    attr_accessor :context

    def initialize(message = nil, context = nil)
      super(message)
      self.context = context
    end
  end

  class BuildingError < BaseError; end
  class MappingError < BaseError; end
  class DispatchingError < BaseError; end
end
