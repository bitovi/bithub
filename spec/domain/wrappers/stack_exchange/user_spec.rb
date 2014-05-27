require 'domain/wrappers/spec_helper'

describe Wrappers::Stackexchange::User do

  let(:raw_user) do
    raw_data(response_path: 'stackexchange/question.json').fetch('owner')
  end

  subject(:user) do
    Wrappers::Stackexchange::User.new(raw_user)
  end

  describe "#user_id" do
    it "should respond with 'user_id' from raw response" do
      expect(user.user_id).to eq raw_user['user_id']
    end
  end

  describe "#display_name" do
    it "should respond with 'display_name' from raw response" do
      expect(user.display_name).to eq raw_user['display_name']
    end
  end

  describe "#link" do
    it "should respond with 'link' from raw response" do
      expect(user.link).to eq raw_user['link']
    end
  end

  describe "#reputation" do
    it "should respond with 'reputation' from raw response" do
      expect(user.reputation).to eq raw_user['reputation']
    end
  end

  describe "#profile_image" do
    it "should respond with 'event_profile_image' from raw response" do
      expect(user.profile_image).to eq raw_user['profile_image']
    end
  end

end
