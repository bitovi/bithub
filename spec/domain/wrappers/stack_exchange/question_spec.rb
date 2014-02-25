require 'domain/wrappers/spec_helper'

describe Wrappers::StackExchange::Question do

  let(:raw_question) do
    raw_data(response_path: 'stackexchange/question.json')
  end
  
  subject(:question) do
    Wrappers::StackExchange::Question.new(raw_question)
  end

  describe "#accepted_answer_id" do
    it "should respond with 'accepted_answer_id' from raw response" do
      expect(question.accepted_answer_id).to eq raw_question['accepted_answer_id']
    end
  end

  describe "#score" do
    it "should respond with 'score' from raw response" do
      expect(question.score).to eq raw_question['score']
    end
  end

  describe "#body_markdown" do
    it "should respond with 'body_markdown' from raw response" do
      expect(question.body_markdown).to eq raw_question['body_markdown']
    end
  end

  describe "#upvote_count" do
    it "should respond with 'up_vote_count' from raw response" do
      expect(question.upvote_count).to eq raw_question['up_vote_count']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw response" do
      expect(question.link).to eq raw_question['link']
    end
  end
  
  describe "#body" do
    it "should respond with 'body' from raw response" do
      expect(question.body).to eq raw_question['body']
    end
  end
    
  describe "#answered?" do
    it "should respond with 'is_answered' from raw response" do
      expect(question.answered?).to eq raw_question['is_answered']
    end
  end
  
  describe "#creation_date" do
    it "should respond with parsed 'creation_date' from raw response" do
      expect(question.creation_date).to eq Time.at(raw_question['creation_date'])
    end
  end
  
  describe "#last_activity_date" do
    it "should respond with parsed 'last_activity_date' from raw response" do
      expect(question.last_activity_date).to eq Time.at(raw_question['last_activity_date'])
    end
  end
  
  describe "#last_edit_date" do
    it "should respond with parsed 'last_edit_date' from raw response" do
      expect(question.last_edit_date).to eq Time.at(raw_question['last_edit_date'])
    end
  end
end
