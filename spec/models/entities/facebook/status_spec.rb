require 'rails_helper'

describe Entities::Facebook::Status do
  describe 'data' do
    it 'prepares the data for building/updating' do
      status_event = Events::Facebook::StatusEvent.new(
        raw_data(response_path: 'facebook/feed.json')[0])

      entity_wrapper = Entities::Facebook::Status.new(status_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include( 'title', 'body', 'url', 'origin_ts', 'origin_id')
      expect(instance.props.keys).to include( 'origin_author_id', 'origin_author_name')
    end
  end
end
