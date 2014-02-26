require 'domain/wrappers/spec_helper'

describe Wrappers::Github::Labels do

  let(:raw_labels) do
    raw_data(response_path: 'github/events/issue_comment_event.json')['payload']['issue']['labels']
  end

  subject(:labels) do
    Wrappers::Github::Labels.new(raw_labels)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(labels.raw).to eq raw_labels
  #   end
  # end

  describe "#names" do
    it "should respond with 'names' from raw data" do
      expect(labels.names).to eq raw_labels.map{|l| l['name']}
    end
  end
  
  describe "#names_csv" do
    it "should respond with 'names_csv' from raw data" do
      expect(labels.names_csv).to eq raw_labels.map{|l| l['name']}.join(',')
    end
  end
  
end
