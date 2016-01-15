module Guzzler

  class GuzzlerError < StandardError; end

  # Fetcher errors
  class FetchError < GuzzlerError; end
  class ConfigError < FetchError; end
  class AuthError < FetchError; end
  class RemoteError < FetchError; end
  class UnknownError < FetchError; end
  class RateLimitError < FetchError; end

  # Persistor errors
  class HandlingError < GuzzlerError; end
  class EventHandlingError < HandlingError; end
  class EntityHandlingError < HandlingError; end

  # Subscription errors
  class SubscriptionError < GuzzlerError; end

  class HandlerAlreadyRegisteredError < GuzzlerError; end

  module Listener
  end

  module Poller
  end

  module Persistor
  end
end
