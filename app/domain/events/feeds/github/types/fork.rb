module Events
  module Github

    class Fork < Protocol
      extend Forwardable
      include Events::Github::Accessors
      
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
