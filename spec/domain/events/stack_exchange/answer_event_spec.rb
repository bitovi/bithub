require 'domain/events/spec_helper'

describe Events::Stackexchange::AnswerEvent do

  let(:raw_answer) do
    raw_data(response_path: 'stackexchange/question.json')['answers'].first
  end

  subject(:answer_event) do
    Events::Stackexchange::AnswerEvent.new(raw_answer)
  end

  describe "#digest_seed" do
    it "should construct the digest_seed from answer_id, last_activity date or creation date and class name" do
      seed =  raw_answer['answer_id'].to_s
      seed += Time.at(raw_answer['last_activity_date'] || raw_answer['creation_date']).utc.to_s
      seed += "Events::Stackexchange::AnswerEvent"

      expect(answer_event.digest_seed).to eq seed
    end
  end

end
