module Fetchers
  module Youtube

    class BadRequestError < StandardError; end
    class ForbiddenError < StandardError; end
    class QuotaExceededError < StandardError; end
  end
end
