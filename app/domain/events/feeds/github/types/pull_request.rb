module Events
  module Github

    class PullRequest < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      
      def_delegator :@repo, :name, :repo_name
      def_delegator :@labels, :label_names_csv, :label_names

      def_delegator :@pull_request, :id, :origin_id
      def_delegator :@pull_request, :id, :pull_request_id
      def_delegators :@pull_request, :body, :title, :references_to

      def digest_seed
        event_id
      end

      def pull_request
        @pull_request ||= Wrappers::Github::PullRequest.new(payload[:pull_request])
      end
      
      def issue_or_pull_req
        pull_request
      end
      
    end
  end
end
