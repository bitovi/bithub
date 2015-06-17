require 'events/protocol'
require_relative 'github_event_accessors'

module Events
  module Github

    class CreateEvent < Protocol
      extend Forwardable
      include GithubEventAccessors
      include GithubEventAccessors::Refs

      attr_reader :actor, :repo

      def digest_seed
        @actor.login + @repo.name + ref_type + ref + self.class.name
      end

      def wrap_response
        @actor = Wrappers::Github::User.new(source_data[:actor])
        @repo = Wrappers::Github::Repo.new(source_data[:repo])
        self
      end

    end
  end
end
