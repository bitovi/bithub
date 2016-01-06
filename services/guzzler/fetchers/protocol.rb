require 'twitter'
require 'github_api'
require 'koala'
require 'instagram'
require 'google/api_client'

module Guzzler
  module Fetchers

    class FetchError < StandardError; end

    class ConfigError < FetchError; end
    class AuthError < FetchError; end
    class RemoteError < FetchError; end
    class UnknownError < FetchError; end
    class RateLimitError < FetchError; end

    module Protocol
      def handle_errors(job = nil)
        yield

      rescue KeyError => e
        if job && job.feed_name == 'tumblr'
          raise ConfigError.new("Blog doesn't exist.")
        end

        raise e
        log_and_return_empty e


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
        raise e
        log_and_return_empty e
      end

      def log_and_return_empty(e)
        Celluloid.logger.error e
        []
      end

      def log_fetch
        Guzzler.logger.info "[FETCHER] Fetching #{self.class.name.gsub('Guzzler::Fetchers::','').gsub('::', '/')}"
      end

      def fetch; end
    end
  end
end
