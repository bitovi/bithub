module Events
  module Disqus

    class PostEvent < Protocol
      extend Forwardable

      def_delegators :@post, :id, :url, :message
      attr_reader :post, :thread, :forum, :author

      def digest_seed
        @post.id + self.class.name
      end

      def wrap_response
        @post = Wrappers::Disqus::Post.new(source_data)
        @author = Wrappers::Disqus::Author.new(source_data[:author]) if source_data[:author]
        @thread = Wrappers::Disqus::Thread.new(source_data[:thread]) if source_data[:thread]
        @forum = Wrappers::Disqus::Forum.new(source_data[:forum]) if source_data[:forum]
        self
      end

    end
  end
end
