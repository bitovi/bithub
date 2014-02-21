module Events
  module Github

    class IssueComment < Protocol
      extend Forwardable
      include Events::Github::Accessors

      def_delegator :@ipr, :id, :issue_or_pull_req_id
      def_delegator :@ipr, :title, :issue_or_pull_req_title
      def_delegator :@ipr, :body, :issue_or_pull_req_body
      def_delegator :@ipr, :number, :issue_or_pull_req_number
      def_delegator :@ipr, :state, :issue_or_pull_req_state
      def_delegator :@ipr, :label_names_csv, :issue_or_pull_req_label_names
      
      def digest_seed
        event_id
      end

      def origin_id
        comment.id
      end

      def comment
        @comment ||= Wrappers::Github::Comment.new(payload[:comment])
      end

      def issue_or_pull_req
        @ipr || i_or_pr
      end

      private
      def i_or_pr
        if payload[:pull_request]
          @ipr ||= Wrappers::Github::Issue.new(payload.andand[:issue])
        elsif payload[:issue]
          @ipr ||= Wrappers::Github::PullRequest.new(payload.andand[:pull_request])
        end
      end
    end

  end
end
