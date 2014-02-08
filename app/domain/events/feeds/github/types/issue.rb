module Events
  module Github

    class Issue < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Labels
      include Events::Github::Accessors::IssuesPullRequests

      def issue
        payload.andand[:issue]
      end

      def issue_id
        issue.andand[:id]
      end
      
      def issue_or_pull_req
        issue
      end

      def origin_id
        issue_id
      end

    end
  end
end
