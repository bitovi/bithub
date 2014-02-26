require 'domain/spec_helper'

class IssueLikeClass
  include Wrappers::Github::IssueLike
  include CoreHelpers

  def initialize(data)
    @i = symbolize_keys(data)
  end
end

describe Wrappers::Github::IssueLike do

  let(:raw_issue) do
    raw_data(response_path: 'github/events/issues_event.json')['payload']['issue']
  end

  subject(:issue_like_object) do
    IssueLikeClass.new(raw_issue)
  end

  describe "#title" do
    it "responds with 'title' from raw data" do
      expect(issue_like_object.title).to eq raw_issue['title']
    end
  end
  
  describe "#body" do
    it "responds with 'body' from raw data" do
      expect(issue_like_object.body).to eq raw_issue['body']
    end
  end
  
  describe "#html_url" do
    it "responds with 'author'->'name' from raw data" do
      expect(issue_like_object.html_url).to eq raw_issue['html_url']
    end
  end
  
  describe "#number" do
    it "responds with 'author'->'email' from raw data" do
      expect(issue_like_object.number).to eq raw_issue['number']
    end
  end
  
  describe "#state" do
    it "responds with 'state' from raw data" do
      expect(issue_like_object.state).to eq raw_issue['state']
    end
  end
  
  describe "#created_at" do
    it "is in UTC" do
      expect(issue_like_object.created_at.zone).to eq "UTC"
    end

    it "pharses the 'created_at' unix ts from raw response" do
      parsed = Time.parse(raw_issue['created_at'])
      expect(issue_like_object.created_at).to eq parsed
    end
  end
  
  describe "#updated_at" do
    it "is in UTC" do
      expect(issue_like_object.updated_at.zone).to eq "UTC"
    end

    it "parses the 'updated_at' unix ts from raw response" do
      parsed = Time.parse(raw_issue['updated_at'])
      expect(issue_like_object.updated_at).to eq parsed
    end
  end

end
