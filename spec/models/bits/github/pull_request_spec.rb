require 'rails_helper'

describe Bits::Github::PullRequest do
  describe 'data' do
    it 'prepares the data for building/updating' do
      pull_request_event = Events::Github::PullRequestEvent.new(
        raw_data(response_path: 'github/events/pull_request_event.json'))

      wrapper = Bits::Github::PullRequest.new(pull_request_event)

      expect(wrapper.data.keys).to include(:title, :body, :url, :origin_ts, :origin_id)
      expect(wrapper.data[:props].keys).to include(:number, :state, :label_names, :origin_author_id, :origin_author_username, :origin_author_avatar_url)
    end
  end
end
