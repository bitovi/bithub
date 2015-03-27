require 'twitter'
require 'github_api'
require 'koala'
require 'instagram'

module Fetchers

  class ServiceError < StandardError; end

  class ConfigError < ServiceError; end
  class AuthError < ServiceError; end
  class RemoteError < ServiceError; end
  class UnknownError < ServiceError; end
  class RateLimitError < ServiceError; end

  module Protocol
    include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
    add_transaction_tracer :fetch, :category => 'OtherTransaction/Fetchers/'

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

  end
end
