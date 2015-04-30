require 'rails_helper'

describe Entities::Twitter::Follow do
  describe 'data' do
    it 'prepares the data for building/updating' do
      fake_follow_event = Events::Twitter::FakeFollowEvent.new(
        raw_data(response_path: 'twitter/fake_follow_event.json'))

      entity_wrapper = Entities::Twitter::Follow.new(fake_follow_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'origin_ts', 'is_pending')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'target_id', 'target_name')
    end
  end
end
