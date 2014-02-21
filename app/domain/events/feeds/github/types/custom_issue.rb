module Events
  module Github

    class CustomIssue < Protocol
      extend Forwardable

      def_delegator :@issue, :id, :issue_id
      def_delegator :@issue, :title, :title
      def_delegator :@issue, :body, :body
      def_delegator :@issue, :html_url, :html_url
      def_delegator :@issue, :labels, :labels
      def_delegator :@issue, :labels_names_csv, :labels_names
      def_delegator :@issue, :number, :number
      def_delegator :@issue, :state, :state

      DigestAttrs = [:issue_id, :title, :body, :label_names, :state, :updated_at]
      
      def digest_seed
        DigestAttrs.reduce("") {|accumul, attr| accumul + self.send(attr).to_s}
      end

      def origin_id
        issue_id
      end

      def issue
        @issue ||= Wrappers::Github::Issue.new(payload)
      end

      def issue_id
        issue.id
      end
      
      def title
        @issue.title
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

      def user_id
        user.andand[:id]
      end

      def user_avatar_url
        user.andand[:avatar_url]
      end

      def user_login
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

      alias_method :actor_id, :user_id
      alias_method :actor_login, :user_login
      alias_method :actor_avatar_url, :user_avatar_url

      alias_method :origin_author_id, :user_id
      alias_method :origin_author_name, :user_login
      alias_method :origin_author_avatar_url, :user_avatar_url
    end

  end
end
