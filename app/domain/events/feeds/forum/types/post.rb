module Events
  module Forum

    class Post < Protocol
      extend Forwardable

      attr_reader :item

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
        @item.pub_date.utc
      end
      
      def wrap_reponse
        @item = Wrappers::Rss::Item.new(source_data)
        self
      end
      
      def_delegators :@item, :title, :link, :category
      alias_method :url, :link
      alias_method :subforum, :category
      alias_method :origin_id, :link
    end

  end
end
