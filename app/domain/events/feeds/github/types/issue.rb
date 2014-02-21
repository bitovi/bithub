module Events
  module Github

    class Issue < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      
      def_delegator :@repo, :name, :repo_name
      def_delegator :@labels, :label_names_csv, :label_names

      def_delegator :@issue, :id, :origin_id
      def_delegator :@issue, :id, :issue_id
      def_delegators :@issue, :body, :title, :references_to

      def digest_seed
        event_id
      end

      def issue
        @issue ||= Wrappers::Github::Issue.new(payload[:issue])
      end
      
      def issue_or_pull_req
        issue
      end


    end
  end
end
