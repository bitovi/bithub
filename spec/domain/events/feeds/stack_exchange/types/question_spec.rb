require 'domain/events/spec_helper'

describe Events::StackExchange::Question do

  let(:raw_question) do
    raw_data(response_path: 'stackexchange/question.json')
  end
  
  subject(:question_wrapper) do
    Wrappers::StackExchange::Question.new(raw_question)
  end

  subject(:question_event) do
    Events::StackExchange::Question.new(raw_question)
  end

  describe "#digest_seed" do
    it "should construct the digest_seed from question_id, last_activity date or creation date and class name" do
      seed =  raw_question['question_id'].to_s
      seed += Time.at(raw_question['last_activity_date'] || raw_question['creation_date']).to_s
      seed += "Events::StackExchange::Question"

      expect(question_event.digest_seed).to eq seed
    end
  end

  describe "#origin_id" do
    it "should delegate to @question->#question_id" do
      expect(question_event.origin_id).to eq question_wrapper.question_id
    end
  end
  
  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(question_event.origin_timestamp.zone).to eq "UTC"
    end
  end

end
