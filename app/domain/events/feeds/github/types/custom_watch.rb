module Events
  module Github

    class CustomWatch < Protocol

      def initialize(repo_name, identity)
        @repo_name = repo_name
        @identity = identity
      end
      
      def source_data
        { identity: @identity, target: @repo_name }
      end

      def content_digest
        seed = identity.uid.to_s + repo.id.to_s
        calc_digest(seed)
      end
      
      def identity_uid
        @identity.uid
      end

      def identity_nickname
        @identity.source_data[:nickname]
      end

      def title
        "starred #{@repo_name}"
      end

      def repo_name
        'bitovi/' + @repo_name
      end

      def taggify_target_repo_name
        [@repo_name]
      end

      def origin_timestamp
        2.years.ago # TODO set to when?
      end

      def fake_avatar_url
        nil
      end

      alias_method :actor_id, :identity_uid
      alias_method :actor_login, :identity_nickname
      alias_method :actor_avatar_url, :fake_avatar_url
    end
  end
end
