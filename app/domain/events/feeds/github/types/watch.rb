module Events
  module Github

    class Watch < Protocol
      extend Forwardable
      include Events::Github::Accessors
      
      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      def_delegator :@repo, :name, :repo_name

      def digest_seed
        actor_id.to_s + repo_name.to_s
      end

    end
  end
end
