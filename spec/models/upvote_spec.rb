require 'spec_helper'

describe Upvote do
  describe ".create_upvote" do
    before :each do
      @actor = create(:user, name: "Some user")
      @event = create(:event_determined)
      @upvote = Upvote.create({actor: @actor, applies_to: @event})
    end

    it "upvotes event" do
      expect(@upvote.applies_to).to eq(@event)
    end

    it "sets the actor" do
      expect(@upvote.actor).to eq(@actor)
    end

    it "sets the value to that of an event's award" do
      expect(@upvote.value).to eq(@event.rule.upvote_value)
    end
  end
end
