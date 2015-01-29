module Fetchers

  class ServiceError < StandardError; end
  class ConfigError < ServiceError; end
  class AuthError < ServiceError; end
  class RemoteError < ServiceError; end
  class UnknownError < ServiceError; end
  class RateLimitError < ServiceError; end

  module Protocol

    def handle_errors
      yield

    # Twitter
    rescue ::Twitter::Error::Unauthorized => e
      raise AuthError.new e.to_s
      log_and_return_empty e
    rescue ::Twitter::Error::TooManyRequests => e
      raise RateLimitError.new e.to_s
      log_and_return_empty e

    # Github
    rescue ::Github::Error::Forbidden => e
      raise AuthError.new e.to_s
      log_and_return_empty
    rescue ::Github::Error::NotFound => e
      raise ConfigError.new("Repo doesn't exist.")
      log_and_return_empty e

    # Tumblr
    rescue KeyError => e
      raise ConfigError.new("Blog doesn't exist.")
      log_and_return_empty e

    # Everything else that's not catastrophic
    rescue => e
      raise UnknownError.new "#{e.class.name} with message #{e.to_s}"
      log_and_return_empty e
    end
  end

  def log_and_return_empty(e)
    Celluloid.logger.error e
    []
  end
end
