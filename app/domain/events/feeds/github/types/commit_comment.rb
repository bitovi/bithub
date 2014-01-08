module Events
  module Github

    class CommitComment
      include Constructable
      include Events::Github::Accessors::Standard
      include Events::Github::Accessors::Comment

      def commit_id
        payload.andand[:comment].andand[:commit_id]
      end

    end

  end
end

# processed.deep_merge({
#   extracted: {
#     :title => "commented on a commit in #{original_hash['repo']['name']}",
#     :body => original_hash['payload']['comment']['body'],
#     :url => original_hash['payload']['comment']['html_url'],
#   },
#   :meta => {
#     :commit_id => original_hash['payload']['comment']['commit_id'],
#   }
# })
