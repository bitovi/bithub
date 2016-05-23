require 'bits/protocol'
require_relative 'shared'

module Bits
  module Github

    class Commit < Protocol
      include Shared

      def initialize(event, commit_wrapper)
        @event = event
        @commit = commit_wrapper
      end

      def find
        @commit.sha && find_by_commit_sha.first
      end

      def data
        with_commons({
          title: title,
          body: @commit.message,
          url: @commit.url,
          origin_id: @commit.sha,
          props: {
            sha: @commit.sha,
          }
        })
      end

      private

      def title
        "pushed to #{@event.repo.name}"
      end

      def find_by_commit_sha
        Bit
        .feed('github')
        .type('commit')
        .where(origin_id: @commit.sha)
      end
    end

  end
end
