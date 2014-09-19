require 'domain/events/spec_helper'

describe Events::Stackexchange::QuestionEvent do

  let(:raw_question) do
    raw_data(response_path: 'stackexchange/question.json')
  end

  subject(:question_event) do
    Events::Stackexchange::QuestionEvent.new(raw_question)
  end

  describe "#digest_seed" do
    it "should construct the digest_seed from question_id, last_activity date or creation date and class name" do
      seed =  raw_question['question_id'].to_s
      seed += Time.at(raw_question['last_activity_date'] || raw_question['creation_date']).utc.to_s
      seed += "Events::Stackexchange::QuestionEvent"

      expect(question_event.digest_seed).to eq seed
    end
  end

end
