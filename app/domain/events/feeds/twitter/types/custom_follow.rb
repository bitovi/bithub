module Events
  module Twitter

    class CustomFollow < Protocol

      def content_digest
        seed = identity_uid.to_s + target_screen_name
        calc_digest(seed)
      end

      def identity_uid
        source_data.andand[:uid]
      end

      def identity_nickname
        source_data.andand[:nickname]
      end

      def target_screen_name
        source_data.andand[:target_screen_name]
      end
      
      def origin_timestamp
        2.years.ago
      end

      def taggify_target_screen_name
        [target_screen_name]
      end

      alias_method :origin_author_id, :identity_uid
      alias_method :origin_author_name, :identity_nickname
      alias_method :target, :target_screen_name
    end

  end
end
