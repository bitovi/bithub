require 'rails_helper'

describe Bits::Stackexchange::Question do
  describe 'data' do
    it 'prepares the data for building/updating' do
      question_event = Events::Stackexchange::QuestionEvent.new(
        raw_data(response_path: 'stackexchange/search.json')['items'][0])

      bit_wrapper = Bits::Stackexchange::Question.new(question_event)
      instance = bit_wrapper.procure.instance

      expect(instance.attributes.keys).to include('title', 'body', 'url', 'origin_id', 'origin_ts')
      expect(instance.props.keys).to include( 'origin_author_id', 'origin_author_name', 'origin_author_avatar_url', 'score', 'accepted_answer_id', 'upvote_count') 
    end
  end
end
