module Events
  module Twitter

    class Follow
      include Constructable

      def content_digest
        Digest::MD5.hexdigest(source_id + target + self.class.name)
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

# processed.deep_merge({
#   extracted: {
#     title: "followed @#{original_hash['target']['screen_name']}",
#     # hash_key: Digest::MD5.hexdigest(original_hash['source']['id_str'] + original_hash['target']['id_str'] + @feed.to_s),
#   },
#   meta: {
#     type: 'follow_event',
#     origin_author_name: original_hash['source']['screen_name'],
#     origin_author_id: original_hash['source']['id'],
#   }
# })
