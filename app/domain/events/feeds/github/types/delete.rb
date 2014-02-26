module Events
  module Github

    class Delete < Protocol
      extend Forwardable
      include Events::Github::Accessors
      include Events::Github::Accessors::Refs

      attr_reader :actor, :repo

      def digest_seed
        @actor.login + @repo.name + ref_type + ref + self.class.name
      end
      
      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        self
      end

    end
  end
end
