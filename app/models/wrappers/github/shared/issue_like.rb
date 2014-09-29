module Wrappers
  module Github

    module IssueLike

      def id
        (@i || @pr).fetch(:id)
      end

      def title
        (@i || @pr).fetch(:title)
      end

      def body
        (@i || @pr).fetch(:body)
      end

      def html_url
        (@i || @pr).fetch(:html_url)
      end

      def number
        (@i || @pr).fetch(:number)
      end

      def state
        (@i || @pr).fetch(:state)
      end

      def created_at
        Time.parse((@i || @pr).fetch(:created_at)).utc
      end

      def updated_at
        Time.parse((@i || @pr).fetch(:updated_at)).utc
      end

    end

  end
end
