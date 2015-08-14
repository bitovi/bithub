require 'twitter'
require 'github_api'
require 'koala'
require 'instagram'
require 'google/api_client'
require 'fetchers/youtube/errors'

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

    # Facebook
    rescue Koala::KoalaError => e
      log_and_return_empty e

    # Youtube
    rescue Google::APIClient::TransmissionError => e
      raise RemoteError.new e.to_s
      log_and_return_empty e
    rescue Fetchers::Youtube::BadRequestError => e
      raise ConfigError.new e.to_s
      log_and_return_empty e
    rescue Fetchers::Youtube::QuotaExceededError => e
      raise RateLimitError.new e.to_s
      log_and_return_empty e
    rescue Fetchers::Youtube::ForbiddenError => e
      raise AuthError.new e.to_s
      log_and_return_empty e

    # Instagram
    rescue ::Instagram::RateLimitExceeded => e
      raise RateLimitError.new e.to_s
      log_and_return_empty e
    rescue ::Instagram::TooManyRequests => e
      raise RateLimitError.new e.to_s
      log_and_return_empty e
    rescue ::Instagram::BadRequest => e
      # token expired or insufficient privileges
      raise AuthError.new e.to_s
      log_and_return_empty e

    # If we cause a Celluloid error, let it propagate
    rescue Celluloid::Error => e
      raise e

    # Everything else that's not catastrophic
    rescue => e
      raise UnknownError.new "#{e.class.name} with message #{e.to_s}"
      log_and_return_empty e
    end

    def log_and_return_empty(e)
      Celluloid.logger.error e
      []
    end

    def fetch; end
  end
end
