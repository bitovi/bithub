module Entities
  class BaseError < Exception
    attr_accessor :context
    def initialize(message = nil, context = nil)
      super(message)
      self.context = context
    end
  end

  class DispatchError < BaseError; end
  class UpdatingError < BaseError; end
  class NormalizationError < BaseError; end
end
