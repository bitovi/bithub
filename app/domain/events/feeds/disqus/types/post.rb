module Events
  module Disqus
    class Post < Protocol

      def origin_id
        # puts "Disqus::Post#origin_id #{source_data}"
        source_data.andand[:id]
      end

      def post_id
        origin_id
      end

      def thread
        source_data.andand[:thread]
      end

      def title
        thread.andand[:title]
      end

      def message
        source_data.andand[:message]
      end

      def url
        source_data.andand[:url]
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
