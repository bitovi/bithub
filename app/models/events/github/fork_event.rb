require 'events/protocol'
require_relative 'github_event_accessors'

module Events
  module Github

    class ForkEvent < Protocol
      extend Forwardable
      include GithubEventAccessors
      
      attr_reader :actor, :repo

      def digest_seed
        @actor.login + @repo.name + self.class.name
      end

      def fork_id
        payload[:fork_id]
      end

      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        self
      end
    end

  end
end
