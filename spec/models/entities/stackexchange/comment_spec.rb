require 'rails_helper'

describe Entities::Stackexchange::Comment do
  describe 'data' do
    it 'prepares the data for building/updating' do
      comment_event = Events::Stackexchange::CommentEvent.new(
        raw_data(response_path: 'stackexchange/search.json')['items'][0]['answers'][0]['comments'][0])

      entity_wrapper = Entities::Stackexchange::Comment.new(comment_event)
      instance = entity_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'score', 'post_id', 'post_type')
    end
  end
end
