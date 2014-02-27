module Events
  module Github

    class Issue < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegators :@issue, :id, :state, :title, :body, :number, :labels
      attr_reader :issue, :repo, :actor

      def digest_seed
        event_id + self.class.name
      end

      def action
        payload.fetch(:action)
      end

      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @issue ||= Wrappers::Github::Issue.new(payload[:issue])
        self
      end

    end
  end
end
