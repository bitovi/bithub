module Events
  module Twitter

    class FollowEvent
      include Constructable

      def content_digest
        Digest::MD5.hexdigest(source_id.to_s + target_id.to_s + self.class.name)
      end

      def source
        source_data.andand[:source]
      end

      def target
        source_data.andand[:target]
      end

      def source_id
        source.andand[:id]
      end

      def target_id
        target.andand[:id]
      end

      def target_screen_name
        target.andand[:screen_name]
      end

      def source_screen_name
        source.andand[:screen_name]
      end
    end

  end
end
