module Events
  module Rss

    class Post < Protocol
      extend Forwardable

      def_delegators :@item, :title, :link, :categories, :summary, :published
      attr_reader :item

      def digest_seed
       link + self.class.name
      end

      def description
        Sanitizer.sanitize(@item.summary)
      end

      def wrap_response
        @item = Wrappers::Rss::Item.new(source_data)
        self
      end

    end
  end
end
