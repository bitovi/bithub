module Events
  module Github

    class CustomIssue < Protocol

      DIGEST_ATTRS = [:issue_id, :title, :body, :labels, :state, :updated_at]
      
      def content_digest
        seed = DIGEST_ATTRS.reduce("") {|accumul, attr| accumul += self.send(attr).to_s}
        Digest::MD5.hexdigest(seed)
      end

      def issue_id
        source_data.andand[:id]
      end
      
      def title
        source_data.andand[:title]
      end

      def body
        source_data.andand[:body]
      end

      def html_url
        source_data.andand[:html_url]
      end

      def labels
        source_data.andand[:labels]
      end

      def label_names
        labels.map {|l| l[:name] }.join(',')
      end

      def state
        source_data.andand[:state]
      end

      def number
        source_data.andand[:number]
      end

      def user
        source_data.andand[:user]
      end

      def origin_author_id
        user.andand[:id]
      end

      def origin_author_avatar_url
        user.andand[:avatar_url]
      end

      def origin_author_name
        user.andand[:login]
      end

      def origin_timestamp
        source_data.andand[:created_at]
      end

      def updated_at
        source_data.andand[:updated_at]
      end
      
      def repo_name
        url = source_data.andand[:url]
        url.match(/repos\/(.*)\/issues/).andand[1]
      end
        
      def referenced_issue_numbers
        body.scan(/#\d+/).map {|m| m.gsub('#','').to_s}
      end

      def referenced_issue_numbers_csv
        referenced_issue_numbers.join(',')
      end

      alias_method :origin_id, :issue_id
      alias_method :actor, :user
      alias_method :actor_id, :origin_author_id
      alias_method :actor_login, :origin_author_name
      alias_method :actor_avatar_url, :origin_author_avatar_url
    end

  end
end
