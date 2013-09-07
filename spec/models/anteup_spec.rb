require 'spec_helper'

describe Anteup do

  before :each do
    @actor = create(:user, name: "Some user")
    @event = create(:event_determined, title: "Event in anteup_spec, before each")

    @anteup = Anteup.create_anteup(@actor, @event, 76)
  end

  describe ".create_anteup" do
    it "sets the target event" do 
      expect(@anteup.applies_to).to eq(@event)
    end

    it "sets the actor" do
      expect(@anteup.actor).to eq(@actor)
    end

    it "sets the desired value" do
      expect(@anteup.value).to eq(76)
    end

    it "sets the initial fullfiled attribute value to false" do
      expect(@anteup.fullfilled).to eq(false)
    end
  end

  describe ".fullfill_anteups" do
    it "sets fullfill to true on anteups belonging to an event" do 
      Anteup.fullfill_by_event(@event)
      expect(@anteup.reload.fullfilled).to eq(true)
    end
  end

end
