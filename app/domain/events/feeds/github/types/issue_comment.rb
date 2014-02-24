module Events
  module Github

    class IssueComment < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      def_delegator :@repo, :name, :repo_name
      
      attr_reader :ipr, :comment, :repo, :actor
      
      def digest_seed
        event_id + self.class.name
      end

      def origin_id
        @comment.id
      end

      def wrap_reponse_parts
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @comment ||= Wrappers::Github::Comment.new(payload[:comment])
        @ipr ||= case payload
                 when payload.andand[:issue]
                   Wrappers::Github::Issue.new(payload.andand[:issue])
                 when payload.andand[:pull_request]
                   Wrappers::Github::PullRequest.new(payload.andand[:pull_request])
                 end
      end

    end

  end
end
