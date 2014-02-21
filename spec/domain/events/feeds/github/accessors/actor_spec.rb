require 'domain/events/spec_helper'

describe Events::Github::Accessors::Actor do

  let(:raw_actor) do
    raw_data(response_path: 'github/events/create_event.json')['actor']
  end

  subject(:actor) do
    Events::Github::Accessors::Actor.new(raw_actor)
  end
  
  # describe "#raw" do
  #   it "it should respond with raw data it was constructed with" do
  #     expect(actor.raw).to eq raw_actor.symbolize_keys
  #   end
  # end

  describe "#id" do
    it "should respond with 'id' from raw data" do
      expect(actor.id).to eq raw_actor['id']
    end
  end
  
  describe "#login" do
    it "should respond with 'login' from raw data" do
      expect(actor.login).to eq raw_actor['login']
    end
  end
  
  describe "#gravatar_id" do
    it "should respond with 'gravatar_id' from raw data" do
      expect(actor.gravatar_id).to eq raw_actor['gravatar_id']
    end
  end

  describe "#avatar_url" do
    it "should respond with 'avatar_url' from raw data" do
      expect(actor.avatar_url).to eq raw_actor['avatar_url']
    end
  end

end
