module Events
  class BaseError < StandardError
    attr_accessor :context

    def initialize(message = nil, context = nil)
      super(message)
      self.context = context
    end
  end

  class BuildingError < BaseError; end
  class DeterminationError < BaseError; end
  class OrphanedEventError < BaseError; end
end
