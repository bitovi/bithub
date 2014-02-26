module Events
  module Blog

    class Post < Protocol
      extend Forwardable

      def_delegators :@item,
        :title, :link, :pub_date,
        :category

      def digest_seed
       link + self.class.name
      end

      def description
        Sanitizer.clean(@item.description)
      end

      def origin_timestamp
        Time.strptime(source_data.andand[:published], "%e %b %Y").utc
      end

      def wrap_reponse_parts
        @item = Wrappers::Rss::Item.new(source_data)
      end

      alias_method :body, :description
      alias_method :origin_id, :link
    end
  end
end
