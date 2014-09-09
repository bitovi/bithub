require 'domain/wrappers/spec_helper'

RSpec.describe Wrappers::Twitter::User, :type => :domain do

  let(:raw_user) do
    raw_data(response_path: 'twitter/status_event.json')['user']
  end

  subject(:user) do
    Wrappers::Twitter::User.new(raw_user)
  end
  
  describe "#id" do
    it "should respond with 'id' from raw data" do
      expect(user.id).to eq raw_user['id']
    end
  end
  
  describe "#screen_name" do
    it "should respond with 'screen_name' from raw data" do
      expect(user.screen_name).to eq raw_user['screen_name']
    end
  end
  
  describe "#profile_image_url" do
    it "should respond with 'profile_image_url' from raw data" do
      expect(user.profile_image_url).to eq raw_user['profile_image_url']
    end
  end

end
