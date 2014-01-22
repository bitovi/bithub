module Events
  module Github

    class PullRequest
      include Constructable
      include Persistable
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
    end

  end
end
