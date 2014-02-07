module Events
  module Github

    class IssueComment < Protocol

      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Labels
      include Events::Github::Accessors::Comments

      def issue
        payload.andand[:issue]
      end
      
      def pull_request
        payload.andand[:pull_request]
      end

      def issue_or_pull_req
        issue || pull_request
      end

      def issue_or_pull_req_id
        issue_or_pull_req.andand[:id]
      end

      def issue_or_pull_req_state
        issue_or_pull_req.andand[:state]
      end
      
      def issue_or_pull_req_title
        issue_or_pull_req.andand[:title]
      end
      
      def issue_or_pull_req_body
        issue_or_pull_req.andand[:body]
      end

      def issue_or_pull_req_label_names
        issue_or_pull_req.andand[:labels]
        .map{|l| l[:name]}.join(',')
      end
        
      def issue_or_pull_req_number
        issue_or_pull_req.andand[:number]
      end

      def issue_wrapper
        Events::Github::Issues.new(issue)
      end

      alias_method :number, :issue_or_pull_req_number
    end

  end
end
