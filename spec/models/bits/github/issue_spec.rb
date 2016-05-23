require 'rails_helper'

describe Bits::Github::Issue do
  describe 'data' do
    it 'prepares the data for building/updating' do
      issue_event = Events::Github::IssueEvent.new(
        raw_data(response_path: 'github/events/issues_event.json'))

      wrapper = Bits::Github::Issue.new(issue_event)

      expect(wrapper.data.keys).to include(:title, :body, :url, :origin_ts, :origin_id)
      expect(wrapper.data[:props].keys).to include(:number, :label_names, :state, :repo_name, :origin_author_id, :origin_author_username, :origin_author_avatar_url)
    end
  end
end
