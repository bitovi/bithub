require 'rails_helper'

describe Entities::Github::Issue do
  describe 'data' do
    it 'prepares the data for building/updating' do
      issue_event = Events::Github::IssueEvent.new(
        raw_data(response_path: 'github/events/issues_event.json'))

      entity_wrapper = Entities::Github::Issue.new(issue_event)

      expect(entity_wrapper.data.keys).to include(
        :title, :body, :url, :origin_ts, :origin_id)

      expect(entity_wrapper.data[:props].keys).to include(
        :origin_author_id, :origin_author_username, :origin_author_avatar_url,
        :repo_name, :number, :label_names, :state)
    end
  end
end
