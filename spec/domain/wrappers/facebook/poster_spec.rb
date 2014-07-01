require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Facebook::Status, :type => :domain do

  let(:raw_from) do
    raw_data(response_path: 'facebook/feed.json').first['from']
  end

  subject(:poster) do
    Wrappers::Facebook::Poster.new(raw_from)
  end
  
  describe "#id" do
    it "should respond with 'from' -> 'id' from raw data" do
      expect(poster.id).to eq raw_from['id']
    end
  end
  
  describe "#name" do
    it "should respond with 'from' -> 'name' from raw data" do
      expect(poster.name).to eq raw_from['name']
    end
  end

end
