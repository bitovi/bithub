require 'domain/wrappers/spec_helper'

describe Wrappers::StackExchange::Comment do

  let(:raw_comment) do
    raw_data(response_path: 'stackexchange/question.json')['comments'].first
  end
  
  subject(:comment) do
    Wrappers::StackExchange::Comment.new(raw_comment)
  end

  describe "#comment_id" do
    it "should respond with 'event_comment_id' from raw response" do
      expect(comment.comment_id).to eq raw_comment['comment_id']
    end
  end

  describe "#post_id" do
    it "should respond with 'post_id' from raw response" do
      expect(comment.post_id).to eq raw_comment['post_id']
    end
  end
  
  describe "#post_type" do
    it "should respond with 'post_type' from raw response" do
      expect(comment.post_type).to eq raw_comment['post_type']
    end
  end
  
  describe "#body" do
    it "should respond with 'body' from raw response" do
      expect(comment.body).to eq raw_comment['body']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw response" do
      expect(comment.link).to eq raw_comment['link']
    end
  end

  describe "#score" do
    it "should respond with 'score' from raw response" do
      expect(comment.score).to eq raw_comment['score']
    end
  end

  describe "#edited" do
    it "should respond with 'edited' from raw response" do
      expect(comment.edited).to eq raw_comment['edited']
    end
  end
  
  describe "#body_markdown" do
    it "should respond with 'body_markdown' from raw response" do
      expect(comment.body_markdown).to eq raw_comment['body_markdown']
    end
  end

  describe "#creation_date" do
    it "should respond with parsed 'creation_date' from raw response" do
      expect(comment.creation_date).to eq Time.at(raw_comment['creation_date'])
    end
  end
    
end
