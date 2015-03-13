require_relative 'fetchers_spec_helper'
require 'fetchers/protocol'

module Fetchers
  class MockFetcher
    include Protocol
  end
end

describe Fetchers::Protocol do

  # TODO Github
  # Github::Error::BadRequest
  # Github::Error::InternalServerError
  # Github::Error::NotAcceptable
  # Github::Error::ServiceUnavailable
  # Github::Error::Unauthorized
  # Github::Error::UnprocessableEntity
  #
  # TODO Instagram
  # Instagram::Error::BadRequest
  # Instagram::Error::NotFound
  # Instagram::Error::TooManyRequests
  # Instagram::Error::InternalServerError
  # Instagram::Error::BadGateway
  # Instagram::Error::ServiceUnavailable
  # Instagram::Error::GatewayTimeout
  # Instagram::Error::InvalidSignature
  # Instagram::Error::RateLimitExceeded
  #
  # TODO Twitter
  # Twitter::Error::BadRequest
  # Twitter::Error::Forbidden
  # Twitter::Error::NotFound
  # Twitter::Error::NotAcceptable
  # Twitter::Error::RequestTimeout
  # Twitter::Error::EnhanceYourCalm
  # Twitter::Error::UnprocessableEntity
  # Twitter::Error::InternalServerError
  # Twitter::Error::BadGateway
  # Twitter::Error::ServiceUnavailable
  # Twitter::Error::GatewayTimeout
  #
  # TODO Koala
  # Koala::Facebook::BadFacebookResponse
  # Koala::Facebook::OAuthTokenRequestError
  # Koala::Facebook::ServerError
  # Koala::Facebook::ClientError

  let(:fetcher) do
    Fetchers::MockFetcher.new
  end

  describe '#handle_errors' do

    it 'transforms Twitter Unauthorized Error to our custom AuthError' do
      expect do
        fetcher.handle_errors do
          raise ::Twitter::Error::Unauthorized
        end
      end.to raise_error(Fetchers::AuthError)
    end

    it 'transforms Twitter TooManyRequests Error to our custom RateLimitError' do
      expect do
        fetcher.handle_errors do
          raise ::Twitter::Error::TooManyRequests
        end
      end.to raise_error(Fetchers::RateLimitError)
    end

    it 'transforms Github Forbidden Error to our custom AuthError' do
      expect do
        fetcher.handle_errors do
          raise ::Github::Error::Forbidden.new(GITHUB_400_RESPONSE)
        end
      end.to raise_error(Fetchers::AuthError)
    end

    it 'transforms Github NotFound Error to our custom ConfigError' do
      expect do
        fetcher.handle_errors do
          raise ::Github::Error::NotFound.new(GITHUB_400_RESPONSE)
        end
      end.to raise_error(Fetchers::ConfigError)
    end

    it 'transforms Instagram errors'

    it 'transforms Facebook errors'

    it 'transforms a base KeyError to our custom ConfigError because Feedjira sucks' do
      expect do
        fetcher.handle_errors do
          raise KeyError
        end
      end.to raise_error(Fetchers::ConfigError)
    end
  end
end
