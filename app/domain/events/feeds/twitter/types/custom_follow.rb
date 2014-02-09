module Events
  module Twitter

    class CustomFollow < Protocol

      def initialize(account, identity)
        @screen_name = account
        @identity = identity
      end

      def source_data
        { identity: @identity, target: @screen_name }
      end

      def content_digest
        seed = @identity.uid.to_s + @screen_name
        calc_digest(seed)
      end

      def origin_author_id
        @identity.uid
      end

      def origin_author_name
        @identity.nickname
      end

      def title
        "followed @#{screen_name}"
      end
      
      def origin_timestamp
        2.years.ago
      end

      def taggify_target_screen_name
        [@account.screen_name]
      end

      class Account
        def initialize(acct)
          @data = acct
        end

        def screen_name
          @data.andand[:screen_name]
        end
      end
    end

  end
end
