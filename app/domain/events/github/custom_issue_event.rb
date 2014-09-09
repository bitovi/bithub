module Events
  module Github

    class CustomIssueEvent < Protocol
      extend Forwardable
      DigestAttrs = [:id, :title, :body, :label_names_csv, :state, :updated_at]

      def_delegators :@issue,
        :id, :title, :body, :html_url,
        :labels, :number, :state

      attr_reader :user, :issue, :repo

      alias_method :actor, :user
      alias_method :ipr, :issue

      def digest_seed
        DigestAttrs.reduce("") do |accumul, attr|
          accumul + self.send(attr).to_s
        end + self.class.name
      end

      def label_names_csv
        @issue.labels.names_csv
      end

      def origin_id
        @issue.id
      end

      def origin_timestamp
        ts_str = source_data.andand[:updated_at]
        Time.parse(ts_str).utc
      end
      alias_method :updated_at, :origin_timestamp

      def repo_name
        url = source_data.andand[:url]
        url.match(/repos\/(.*)\/issues/).andand[1]
      end

      def wrap_response
        @issue = Wrappers::Github::Issue.new(source_data)
        @user = Wrappers::Github::User.new(source_data[:user])
        @repo = FakeRepo.new(repo_name)
        self
      end
    end
    
    class FakeRepo
      attr_reader :repo_name
      def initialize(name)
        @repo_name = name
      end
    end
    
  end
end
