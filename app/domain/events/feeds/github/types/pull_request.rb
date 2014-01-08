module Events
  module Github

    class PullRequest
      include Constructable
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

# if m = ("" + original_hash['payload']['pull_request']['title'] + original_hash['payload']['pull_request']['body']).match(/#(\d*)/)
#   issue_nmb = m[1]
# end

# t = original_hash['payload']['pull_request']['title']
# nmb = original_hash['payload']['pull_request']['number']
# state = original_hash['payload']['pull_request']['state']
# action = original_hash['payload']['action']

# title = "Pull request ##{nmb} #{action}: #{t}"

# new_data = {
#   extracted: {
#     :title => title,
#     :body => original_hash['payload']['pull_request']['body'],
#     :url => original_hash['payload']['pull_request']['html_url'],
#   },
#   meta: {
#     :repo_name => original_hash['repo']['name'],
#     :referenced_issue_number => issue_nmb,
#     :issue_number => nmb,
#     :action => action,
#     :state => state,
#   }
# }

# processed.deep_merge(new_data)
