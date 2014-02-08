module Events
  module Github

    class PullRequestReviewComment < Protocol
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Comments
    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "commented on pull request: #{original_hash['payload']['comment']['path']}",
#     :url => original_hash['payload']['comment']['_links']['html']['href'],
#       :body => original_hash['payload']['comment']['body'],
#   }
# })
