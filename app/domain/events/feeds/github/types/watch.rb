module Events
  module Github

    class Watch < Protocol
      extend Forwardable
      include Events::Github::Accessors

      attr_reader :actor, :repo
      
      def digest_seed
        @actor.id.to_s + @repo.name + self.class.name
      end

      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        self
      end
    end
  end
end
