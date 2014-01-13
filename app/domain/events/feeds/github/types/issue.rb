module Events
  module Github

    class IssuesEvent
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Labels
      include Events::Github::Accessors::IssuesPullRequests

      def issue
        payload.andand[:issue]
      end

      def issue_or_pull_req
        issue
      end

      def issue_id
        issue.andand[:id]
      end
    end

  end
end
