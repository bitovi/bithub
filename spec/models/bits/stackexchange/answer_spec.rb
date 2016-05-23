require 'rails_helper'

describe Bits::Stackexchange::Answer do
  describe 'data' do
    it 'prepares the data for building/updating' do
      answer_event = Events::Stackexchange::AnswerEvent.new(
        raw_data(response_path: 'stackexchange/search.json')['items'][0]['answers'][0])

      bit_wrapper = Bits::Stackexchange::Answer.new(answer_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include('origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'score', 'is_accepted', 'upvote_count', 'question_id')
    end
  end
end
