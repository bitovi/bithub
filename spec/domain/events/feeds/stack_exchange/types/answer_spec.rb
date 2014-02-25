require 'domain/events/spec_helper'

describe Events::StackExchange::Answer do

  let(:raw_answer) do
    raw_data(response_path: 'stackexchange/question.json')['answers'].first
  end
  
  subject(:answer_wrapper) do
    Wrappers::StackExchange::Answer.new(raw_answer)
  end

  subject(:answer_event) do
    Events::StackExchange::Answer.new(raw_answer)
  end

  describe "#digest_seed" do
    it "should construct the digest_seed from answer_id, last_activity date or creation date and class name" do
      seed =  raw_answer['answer_id'].to_s
      seed += Time.at(raw_answer['last_activity_date'] || raw_answer['creation_date']).to_s
      seed += "Events::StackExchange::Answer"

      expect(answer_event.digest_seed).to eq seed
    end
  end

  describe "#origin_id" do
    it "should delegate to @answer->#answer_id" do
      expect(answer_event.origin_id).to eq answer_wrapper.answer_id
    end
  end
  
  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(answer_event.origin_timestamp.zone).to eq "UTC"
    end
  end

end
