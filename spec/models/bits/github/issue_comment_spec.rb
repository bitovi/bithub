require 'rails_helper'

describe Bits::Github::IssueComment do
  describe 'data' do
    it 'prepares the data for building/updating' do
      issue_comment_event = Events::Github::IssueCommentEvent.new(
        raw_data(response_path: 'github/events/issue_comment_event.json'))

      wrapper = Bits::Github::IssueComment.new(issue_comment_event)

      expect(wrapper.data.keys).to include(:title, :body, :url, :origin_ts, :origin_id)
      expect(wrapper.data[:props].keys).to include(:number, :repo_name, :origin_author_id, :origin_author_username, :origin_author_avatar_url)
    end
  end
end
