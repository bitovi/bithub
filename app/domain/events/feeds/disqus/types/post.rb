module Events
  module Disqus

    class Post < Protocol
      extend Forwardable

      attr_reader :post, :thread, :author

      def digest_seed
        @post.id + self.class.name
      end

      def origin_timestamp
        @post.created_at.utc
      end

      def wrap_reponse
        @post = Wrappers::Disqus::Post.new(source_data)
        @author = Wrappers::Disqus::Author.new(source_data[:author]) if source_data[:author]
        @thread = Wrappers::Disqus::Thread.new(source_data[:thread]) if source_data[:thread]
        @forum = Wrappers::Disqus::Forum.new(source_data[:forum]) if source_data[:forum]
        self
      end

      def_delegator :@post, :id, :origin_id
      def_delegator :@author, :id, :origin_author_id
      def_delegator :@author, :name, :origin_author_name
    end
  end
end
