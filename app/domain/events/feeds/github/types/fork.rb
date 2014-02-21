module Events
  module Github

    class Fork < Protocol
      extend Forwardable
      include Events::Github::Accessors
      
      def_delegators :@actor,
        :origin_author_id,
        :origin_author_name,
        :origin_author_avatar_url
      
      def_delegator :@repo, :name, :repo_name


      def digest_seed
        actor.login + repo.name + fork_id
      end

      def fork_id
        # event_id ? really FIXME
      end

    end

  end
end
