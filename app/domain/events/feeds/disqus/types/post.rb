module Events
  module Disqus
    class Post < Protocol

      def origin_id
        post_id
      end

      def post_id
        source_data.andand[:id]
      end

      def thread_title
        source_data.andand[:thread].andand[:title]
      end

      def message
        source_data.andand[:message]
      end

      def url
        source_data.andand[:url]
      end

      def author_name
        source_data.andand[:author].andand[:name]
      end

      # Disqus provides date in format: "2013-02-14T22:47:29",
      # we append 'Z' to designate that the date is in UTC.
      # (Disqus API docs say so)
      def origin_timestamp
        Time.parse(source_data.andand[:createdAt]+'Z').utc
      end
      
      alias_method :title, :thread_title
      alias_method :origin_author_name, :author_name
    end
  end
end
