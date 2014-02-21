module Events
  module Github

    class PullRequestReviewComment < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      
      def_delegator :@repo, :name, :repo_name

      def_delegator :@comment, :id, :origin_id
      def_delegator :@comment, :id, :comment_id
      def_delegators :@comment,
        :body,
        :title,
        :commit_id,
        :references_to
      
      def digest_seed
        event_id
      end

      def comment
        @comment ||= Wrappers::Github::Comment.new(payload[:comment])
      end

    end

  end
end
