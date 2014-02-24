module Events
  module Github

    class CustomIssue < Protocol
      extend Forwardable
      DigestAttrs = [:id, :title, :body, :label_names_csv, :state, :updated_at]

      def_delegators :@issue,
        :id,
        :title,
        :body,
        :html_url,
        :labels,
        :number,
        :state

      def_delegators :@labels,
        :label_names,
        :label_names_csv

      def_delegator :@user, :id, :user_id
      def_delegator :@user, :login, :user_login
      def_delegator :@user, :avatar_url, :user_avatar_url
      
      def digest_seed
        DigestAttrs.reduce("") do |accumul, attr|
          accumul + self.send(attr).to_s
        end + self.class.name
      end

      def origin_id
        @issue.id
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
        
      def wrap_reponse_parts
        @issue = Wrappers::Github::Issue.new(source_data)
        @labels = @issue.user
        @labels = @issue.labels
      end

      alias_method :actor_id, :user_id
      alias_method :actor_login, :user_login
      alias_method :actor_avatar_url, :user_avatar_url
      alias_method :origin_author_id, :user_id
      alias_method :origin_author_name, :user_login
      alias_method :origin_author_avatar_url, :user_avatar_url
    end

  end
end
