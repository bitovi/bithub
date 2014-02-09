module Events
  module Github

    class CustomWatch < Protocol

      def content_digest
        seed = identity_uid.to_s + repo_name
        calc_digest(seed)
      end
      
      def identity_uid
        source_data.andand[:uid]
      end

      def identity_nickname
        source_data.andand[:nickname]
      end

      def repo_name
        ['bitovi', source_data.andand[:repo_name]].compact.join('/')
      end

      def origin_timestamp
        2.years.ago
      end

      def taggify_target_repo_name
        [repo_name]
      end

      alias_method :actor_id, :identity_uid
      alias_method :actor_login, :identity_nickname
    end
  end
end
