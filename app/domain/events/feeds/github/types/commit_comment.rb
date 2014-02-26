module Events
  module Github

    class CommitComment < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegators :@comment, :id, :body, :title,
        :commit_id, :references_to

      attr_reader :comment, :actor, :repo
      
      def digest_seed
        event_id + self.class.name
      end
      
      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @comment ||= Wrappers::Github::Comment.new(payload[:comment])
      end

    end
  end
end
