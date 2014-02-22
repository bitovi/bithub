module Events
  module Disqus

    class Post < Protocol
      extend Forwardable

      def_delegators :@post, :id, :message, :url
      def_delegators :@thread, :title
      def_delegator :@author, :id, :origin_author_id
      def_delegator :@author, :name, :origin_author_name

      def digest_seed
        post.id + self.class.name
      end

      def origin_id
        post.id
      end

      def origin_timestamp
        @post.created_at.utc
      end

      def wrap_reponse_parts
        @post = Wrappers::Disqus::Post.new(source_data)
        @thread = @post.thread
        @author = @post.author
      end

    end
  end
end
