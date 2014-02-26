module Events
  module Forum

    class Post < Protocol
      extend Forwardable

      def_delegators :@item,
        :title, :link, :pub_date,
        :category

      def digest_seed
        link + self.class.name
      end

      def origin_author_name
        source_data.andand[:'dc:creator']
      end

      def term
        meta.andand[:term]
      end

      def description
        Sanitizer.sanitize_forum_post(@item.description)
      end

      def origin_timestamp
        pub_date.utc
      end
      
      def wrap_reponse_parts
        @item = Wrappers::Rss::Item.new(source_data)
      end
      
      alias_method :body, :description
      alias_method :url, :link
      alias_method :subforum, :category
      alias_method :origin_id, :link
    end

  end
end
