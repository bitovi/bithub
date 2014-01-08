module Events
  module Disqus
    class Post
      include Constructable

      def content_digest
        @digest ||= Digest::MD5.hexdigest(post_id + self.class.name)
      end

      def post_id
        source_data.andand[:id]
      end

      def origin_author_name
        source_data.andand[:author].andand[:name]
      end

      def origin_timestamp
        # Disqus provides date in format: "2013-02-14T22:47:29" !!! we append 'Z'
        Time.parse(source_data.andand[:createdAt]+'Z').utc
      end
    end

  end
end

# extracted: {
#   title: original_hash['thread']['title'],
#   body: original_hash['message'],
#   url: original_hash['url'],
# },
