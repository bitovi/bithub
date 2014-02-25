require 'domain/wrappers/spec_helper'

describe Wrappers::StackExchange::Answer do

  let(:raw_answer) do
    raw_data(response_path: 'stackexchange/question.json')['answers'].first
  end
  
  subject(:answer) do
    Wrappers::StackExchange::Answer.new(raw_answer)
  end

  describe "#answer_id" do
    it "should respond with 'answer_id' from raw response" do
      expect(answer.answer_id).to eq raw_answer['answer_id']
    end
  end

  describe "#question_id" do
    it "should respond with 'question_id' from raw response" do
      expect(answer.question_id).to eq raw_answer['question_id']
    end
  end

  describe "#score" do
    it "should respond with 'score' from raw response" do
      expect(answer.score).to eq raw_answer['score']
    end
  end

  describe "#title" do
    it "should respond with 'event_title' from raw response" do
      expect(answer.title).to eq raw_answer['title']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw response" do
      expect(answer.link).to eq raw_answer['link']
    end
  end
  
  describe "#body" do
    it "should respond with 'body' from raw response" do
      expect(answer.body).to eq raw_answer['body']
    end
  end
  
  describe "#accepted?" do
    it "should respond with 'is_accepted' from raw response" do
      expect(answer.accepted?).to eq raw_answer['is_accepted']
    end
  end
  
  describe "#creation_date" do
    it "should respond with parsed 'creation_date' from raw response" do
      expect(answer.creation_date).to eq Time.at(raw_answer['creation_date'])
    end
  end
  
  describe "#last_activity_date" do
    it "should respond with parsed 'last_activity_date' from raw response" do
      expect(answer.last_activity_date).to eq Time.at(raw_answer['last_activity_date'])
    end
  end
    
end
