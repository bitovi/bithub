require 'rails_helper'

describe Entities::Github::Issue do
  describe 'data' do
    it 'prepares the data for building/updating' do
      pull_request_event = Events::Github::PullRequestEvent.new(
        raw_data(response_path: 'github/events/pull_request_event.json'))

      entity_wrapper = Entities::Github::PullRequest.new(pull_request_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_ts', 'origin_id')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'number', 'label_names', 'state') # 'origin_author_username'
    end
  end
end
