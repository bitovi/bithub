require 'rails_helper'

describe Entities::Github::Issue do
  describe 'data' do
    it 'prepares the data for building/updating' do
      issue_event = Events::Github::IssueEvent.new(
        raw_data(response_path: 'github/events/issues_event.json'))

      entity_wrapper = Entities::Github::Issue.new(issue_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_ts', 'origin_id')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'repo_name', 'number', 'label_names', 'state') # 'origin_author_username'
    end
  end
end
