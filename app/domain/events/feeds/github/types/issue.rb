module Events
  module Github

    class Issue
      include Constructable
      include Events::Github::Accessors::Standard
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

# t = original_hash['payload']['issue']['title']
# nmb = original_hash['payload']['issue']['number']
# state = original_hash['payload']['issue']['state']
# action = original_hash['payload']['action']

# if action == 'opened'
#   title = t
# else
#   title = "Issue #{action}"
# end

# new_data = {
#   extracted: {
#     :title => title,
#     :body => original_hash['payload']['issue']['body'],
#     :url => original_hash['payload']['issue']['html_url'],
#   },
#   :meta => {
#     :labels => label_names(labels(original_hash)),
#     :issue_id => original_hash['payload']['issue']['id'],
#     :action => original_hash['payload']['action'],
#     :repo_name => original_hash['repo']['name'],
#     :state => state,
#     :issue_number => nmb
#   }
# }

# if action != 'opened'
#   new_data[:meta][:type] = 'issue_action'
# end

# processed.deep_merge(new_data)
