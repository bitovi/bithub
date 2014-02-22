module Events
  module Github

    class Create < Protocol
      include Events::Github::Accessors
      include Events::Github::Accessors::Refs

      def_delegator :@actor, :id, :origin_author_id
      def_delegator :@actor, :login, :origin_author_name
      def_delegator :@actor, :avatar_url, :origin_author_avatar_url
      def_delegator :@repo, :name, :repo_name

      def digest_seed
        actor.login + repo.name + ref_type + ref + self.class.name
      end

      def wrap_reponse_parts
        @actor ||= Wrappers::Github::User.new(source_data[:actor])
        @repo ||= Wrappers::Github::Repo.new(source_data[:repo])
      end

    end
  end
end
