module Events
  module Blog

    class Post < Protocol
      extend Forwardable

      def_delegators :@item, :title, :link, :category
      attr_reader :item

      def digest_seed
       link + self.class.name
      end

      def description
        Sanitizer.sanitize(@item.description)
      end

      def pub_date
        Time.strptime(source_data.andand[:published], "%e %b %Y").utc
      end

      def wrap_reponse
        @item = Wrappers::Rss::Item.new(source_data)
        self
      end

    end
  end
end
