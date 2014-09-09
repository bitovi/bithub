require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Github::User, :type => :domain do

  let(:raw_user) do
    raw_data(response_path: 'github/events/create_event.json')['actor']
  end

  subject(:user) do
    Wrappers::Github::User.new(raw_user)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(user.raw).to eq raw_user.symbolize_keys
  #   end
  # end

  describe "#id" do
    it "should respond with 'id' from raw data" do
      expect(user.id).to eq raw_user['id']
    end
  end
  
  describe "#login" do
    it "should respond with 'login' from raw data" do
      expect(user.login).to eq raw_user['login']
    end
  end
  
  describe "#gravatar_id" do
    it "should respond with 'gravatar_id' from raw data" do
      expect(user.gravatar_id).to eq raw_user['gravatar_id']
    end
  end

  describe "#avatar_url" do
    it "should respond with 'avatar_url' from raw data" do
      expect(user.avatar_url).to eq raw_user['avatar_url']
    end
  end

end
