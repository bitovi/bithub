module Accessors
  module General


    def feed_type
      [feed, type]
    end

    def url
      @data.andand[:extracted].andand[:url]
    end
  end

  module Bithub
  end

  module Blog
    def post_id
      @data.andand[:meta].andand[:post_id]
    end
  end

  module Disqus
    def post_id
      @data.andand[:meta].andand[:post_id]
    end
  end

  module Forum
    def url
      @data.andand[:extracted].andand[:url]
    end
  end
  
  module Twitter
  end

end

