module Events
  module Github

    class PullRequest < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      def_delegator :@repo, :name, :repo_name

      def_delegators :@pull_request, :id, :body, :title, :references_to

      def digest_seed
        event_id + self.class.name
      end

      def wrap_reponse_parts
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @pull_request ||= Wrappers::Github::PullRequest.new(payload[:pull_request])
      end
      
    end
  end
end
