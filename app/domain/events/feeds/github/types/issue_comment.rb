module Events
  module Github

    class IssueComment
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::IssuesPullRequests
      include Events::Github::Accessors::Comment
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "commented on issue #{original_hash['payload']['issue']['number']}",
#     :body => original_hash['payload']['comment']['body'],
#     :url => original_hash['payload']['issue']['html_url'],
#   },
#   meta: {
#     :labels => label_names(labels(original_hash)),
#     :issue_id => original_hash['payload']['issue']['id'],
#     :issue_number => original_hash['payload']['issue']['number'],
#     :repo_name => original_hash['repo']['name']
#   }
# })
