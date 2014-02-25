require 'domain/events/spec_helper'

describe Events::StackExchange::Comment do

  let(:raw_comment) do
    raw_data(response_path: 'stackexchange/question.json')['comments'].first
  end
  
  subject(:comment_wrapper) do
    Wrappers::StackExchange::Comment.new(raw_comment)
  end

  subject(:comment_event) do
    Events::StackExchange::Comment.new(raw_comment)
  end

  describe "#digest_seed" do
    it "should construct the digest_seed from comment_id, last_activity date or creation date and class name" do
      seed =  raw_comment['comment_id'].to_s
      seed += Time.at(raw_comment['last_activity_date'] || raw_comment['creation_date']).to_s
      seed += "Events::StackExchange::Comment"

      expect(comment_event.digest_seed).to eq seed
    end
  end

  describe "#origin_id" do
    it "should delegate to @comment->#comment_id" do
      expect(comment_event.origin_id).to eq comment_wrapper.comment_id
    end
  end
  
  describe "#origin_timestamp" do
    it "should be in UTC" do
      expect(comment_event.origin_timestamp.zone).to eq "UTC"
    end
  end

end
