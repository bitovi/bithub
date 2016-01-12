require 'twitter'
require 'github_api'
require 'koala'
require 'instagram'
require 'google/api_client'
require 'guzzler/error'

module Guzzler

  module Fetchers
    module Protocol
      def handle_errors(job = nil)
        yield

      rescue KeyError => e
        if job && job.feed_name == 'tumblr'
          raise Guzzler::ConfigError.new("Blog doesn't exist.")
        end

        raise e
        log_and_return_empty e


        # Twitter
      rescue ::Twitter::Error::Unauthorized => e
        raise Guzzler::AuthError.new e.to_s
        log_and_return_empty e
      rescue ::Twitter::Error::TooManyRequests => e
        raise Guzzler::RateLimitError.new e.to_s
        log_and_return_empty e

        # Github
      rescue ::Github::Error::Forbidden => e
        raise Guzzler::AuthError.new e.to_s
        log_and_return_empty
      rescue ::Github::Error::NotFound => e
        raise Guzzler::ConfigError.new("Repo doesn't exist.")
        log_and_return_empty e

        # Facebook
      rescue Koala::KoalaError => e
        log_and_return_empty e

        # Youtube
      rescue Google::APIClient::TransmissionError => e
        raise Guzzler::RemoteError.new e.to_s
        log_and_return_empty e
      rescue Fetchers::Youtube::BadRequestError => e
        raise Guzzler::ConfigError.new e.to_s
        log_and_return_empty e
      rescue Fetchers::Youtube::QuotaExceededError => e
        raise Guzzler::RateLimitError.new e.to_s
        log_and_return_empty e
      rescue Fetchers::Youtube::ForbiddenError => e
        raise Guzzler::AuthError.new e.to_s
        log_and_return_empty e

        # Instagram
      rescue ::Instagram::RateLimitExceeded => e
        raise Guzzler::RateLimitError.new e.to_s
        log_and_return_empty e
      rescue ::Instagram::TooManyRequests => e
        raise Guzzler::RateLimitError.new e.to_s
        log_and_return_empty e
      rescue ::Instagram::BadRequest => e
        # token expired or insufficient privileges
        raise Guzzler::AuthError.new e.to_s
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
