module Entities
  module Accessors
    def extracted(payload)
      payload['extracted']
    end

    def meta(payload)
      payload['meta']
    end

    def feed(payload)
      payload['meta']['feed']
    end

    def type(payload)
      payload['meta']['type']
    end

    def url(payload)
      payload['extracted']['url']
    end
  end

  module Blog
    module Accessors
      def post_id(payload)
        payload['meta']['post_id']
      end
    end
  end

  module Disqus
    module Accessors
      def post_id(payload)
        payload['meta']['post_id']
      end
    end
  end

  module Forum
    module Accessors
      def url(payload)
        payload['extracted']['url']
      end
    end
  end

  module Github
    module Accessors
      def issue_id(payload)
        payload['meta']['issue_id']
      end

      def push_id(payload)
        payload['meta']['push_id']
      end

      def repo_name(payload)
        payload['meta']['repo_name']
      end

      def issue_number(payload)
        payload['meta']['issue_number']
      end
    end
  end
end
