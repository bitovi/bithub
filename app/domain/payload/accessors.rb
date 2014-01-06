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
    # All events
    def repo_name
      @data[:source_data].andand[:repo].andand[:name]
    end

    # Issue, Pull-request
    def issue_id
      @data[:source_data].andand[:payload].andand[:issue].andand[:id]
    end
    
    def pull_request_id
      @data[:source_data].andand[:payload].andand[:pull_request].andand[:id]
    end

    def issue_or_pull_req_number
      if i = @data[:source_data].andand[:payload].andand[:issue] 
        i.andand[:number]
      elsif pr = @data[:source_data].andand[:payload].andand[:pull_request]
        pr.andand[:number]
      end
    end
    
    def referenced_repo_name
      repo_name
    end
    
    # Push
    def push_id
      @data[:source_data].andand[:payload].andand[:push_id]
    end

    def commit_shas
      @data[:source_data].andand[:payload].andand[:commits].map{|c| c[:sha]}.join(',')
    end
    
    def referenced_number
      if commits = @data[:source_data].andand[:payload].andand[:commits]
        md = commits.map{|c| c[:message]}.join(' ').match(/#(\d*)/)
      end
      md.andand[1]
    end
    
    # Commit Comment
    def commit_id
      @data[:source_data].andand[:payload].andand[:comment].andand[:commit_id]
    end
  end

end

