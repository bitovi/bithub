module Events
  module Github

    class PullRequest < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::IssuesPullRequests

      def pull_request
        payload.andand[:pull_request]
      end

      def issue_or_pull_req
        pull_request
      end

      def pull_request_id
        pull_request.andand[:id]
      end

      def origin_id
        pull_request_id
      end
    end

  end
end
