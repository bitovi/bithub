require 'events/protocol'

module Events
  module Tumblr

    class PostEvent < Protocol
      extend Forwardable

      def_delegators :@post, :blog_name, :post_url, :type, :timestamp, :tags, :source_url, :source_title
      alias_method :link, :post_url

      def id
        @post.id.to_s
      end

      def digest_seed
        id.to_s + self.class.name
      end

      def created_at
        Time.at timestamp.to_i
      end

      def wrap_response
        @post ||= Wrappers::Tumblr::Post.new source_data
        self
      end
    end

  end
end
