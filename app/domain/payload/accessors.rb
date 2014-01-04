module Accessors
  module General
    def extracted
      @data.andand[:extracted]
    end

    def meta
      @data.andand[:meta]
    end

    def feed
      @data.andand[:meta].andand[:feed]
    end

    def type
      @data.andand[:meta].andand[:type]
    end

    def content_digest
      @data.andand[:content_digest]
    end

    def source_data
      @data.andand[:source_data]
    end

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

  module Github
    def issue_id
      @data.andand[:meta].andand[:issue_id]
    end

    def push_id
      @data.andand[:meta].andand[:push_id]
    end

    def repo_name
      @data.andand[:meta].andand[:repo_name]
    end

    def issue_number
      @data.andand[:meta].andand[:issue_number]
    end
    
    def referenced_repo_name
      if (ref = @data.andand[:meta].andand[:referenced_repo_name])
        ref
      else
        repo_name
      end
    end

    def referenced_issue_number
      @data.andand[:meta].andand[:referenced_issue_number]
    end
  end

end

