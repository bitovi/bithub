module Events
  module Github

    class IssueCommentEvent
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Labels
      include Events::Github::Accessors::IssuesPullRequests
      include Events::Github::Accessors::Comments

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
