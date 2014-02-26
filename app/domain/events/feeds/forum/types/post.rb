module Events
  module Forum

    class Post < Protocol
      extend Forwardable

      def_delegators :@item, :title, :link, :category, :pub_date
      attr_reader :item

      def digest_seed
        link + self.class.name
      end

      def creator
        source_data[:'dc:creator']
      end

      def term
        meta[:term]
      end

      def description
        Sanitizer.sanitize_forum_post(@item.description)
      end

      def wrap_reponse
        @item = Wrappers::Rss::Item.new(source_data)
        self
      end
      
      alias_method :subforum, :category
    end

  end
end
