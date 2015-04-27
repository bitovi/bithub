require 'rails_helper'

describe Entities::Github::Issue do
  describe 'data' do
    it 'prepares the data for building/updating' do
      pull_request_event = Events::Github::PullRequestEvent.new(
        raw_data(response_path: 'github/events/pull_request_event.json'))

      entity_wrapper = Entities::Github::PullRequest.new(pull_request_event)

      expect(entity_wrapper.data.keys).to include(
        :title, :body, :url, :origin_ts, :origin_id)

      expect(entity_wrapper.data[:props].keys).to include(
        :origin_author_id, :origin_author_username,
        :origin_author_avatar_url, :number,
        :label_names, :state)
    end
  end
end
