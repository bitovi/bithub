module Bits
  class BaseError < StandardError
    attr_accessor :context
    def initialize(message = nil, context = nil)
      super(message)
      self.context = context
    end
  end

  class UpdatingError < BaseError; end
  class DeterminationError < BaseError; end
  class NormalizationError < BaseError; end
end
