module Events
  module Github

    class PullRequestEvent < Protocol
      extend Forwardable
      include Events::Github::GithubEventAccessors

      def_delegators :@pull_request, :id, :state, :title, :body, :number, :labels
      attr_reader :pull_request, :repo, :actor

      def digest_seed
        event_id + self.class.name
      end

      def origin_id
        @pull_request.id
      end
      
      def action
        payload.fetch(:action)
      end
      
      def ipr
        @pull_request
      end

      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @pull_request ||= Wrappers::Github::PullRequest.new(payload[:pull_request])
        self
      end
      
    end
  end
end
