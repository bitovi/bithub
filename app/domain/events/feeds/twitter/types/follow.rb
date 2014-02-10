module Events
  module Twitter

    class Follow < Protocol

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

      def origin_ts
        Time.parse(source_data.andand[:created_at]).utc
      end

      alias_method :origin_author_id, :source_id
      alias_method :origin_author_name, :source_screen_name

      private

      def we_are_target?(source_data)
        %w(bitovi canjs javascriptmvc jquerypp stealjs funcunit bitovi_bithub).include? target_screen_name
      end

      def we_are_source?(event_hash)
        %w(bitovi canjs javascriptmvc jquerypp stealjs funcunit bitovi_bithub).include? source_screen_name
      end
    end

  end
end
