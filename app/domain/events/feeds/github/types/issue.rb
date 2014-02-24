module Events
  module Github

    class Issue < Protocol
      extend Forwardable
      include Events::Github::Accessors

      attr_reader :issue

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      def_delegator :@repo, :name, :repo_name

      def_delegators :@issue, :id, :body, :title, :references_to

      def digest_seed
        event_id + self.class.name
      end

      def issue_or_pull_req
        issue
      end

      def wrap_reponse_parts
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
        @issue ||= Wrappers::Github::Issue.new(payload[:issue])
      end

    end
  end
end
