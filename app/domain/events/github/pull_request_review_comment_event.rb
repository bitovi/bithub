module Events
  module Github

    class PullRequestReviewCommentEvent < Protocol
      extend Forwardable
      include Events::Github::GithubEventAccessors

      def_delegators :@comment, :id, :body, :title, :references_to
      attr_reader :actor, :repo, :comment
      
      def digest_seed
        event_id + self.class.name
      end

      def wrap_response
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @comment ||= Wrappers::Github::Comment.new(payload[:comment])
        self
      end

    end

  end
end
