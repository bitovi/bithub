require 'spec_helper'

describe Upvote do
  before :each do
    create(:rule)
    @actor = create(:user, name: "Some user")
    @event = create(:event_determined)
  end

  describe ".create_upvote" do
    it "upvotes event" do
      upvote = Upvote.create_upvote(@actor, @event)
      expect(upvote.applies_to).to eq(@event)
      expect(upvote.actor).to eq(@actor)
      expect(upvote.value).to eq(@event.rule.upvote_value)
      #expect(@event.reload.author.events_upvoted).to include(activity.applies_to)
    end
  end
end


describe Anteup do
  before :each do
    create(:rule)
    @actor = create(:user, name: "Some user")
    @event = create(:event_determined)
  end

  describe ".create_anteup" do
    it "places anteup on event" do 
      anteup_value = 25
      anteup = Anteup.create_anteup(@actor, @event, anteup_value)
      expect(anteup.applies_to).to eq(@event)
      expect(anteup.actor).to eq(@actor)
      expect(anteup.value).to eq(anteup_value)
      expect(anteup.fullfilled).to eq(false)
    end
  end

  describe ".fullfill_anteups" do
    it "sets fullfill to true on anteups belonging to an event" do 
      anteup_value = 25
      @event2 = create(:event_determined)
      anteup = Anteup.create_anteup(@actor, @event, anteup_value)
      anteup2 = Anteup.create_anteup(@actor, @event2, anteup_value)
      Anteup.fullfill_by_event(@event)
      expect(anteup.reload.fullfilled).to eq(true)
      expect(anteup2.reload.fullfilled).to eq(false)
    end
  end

end

describe Award do
  describe ".create_award" do
    it "awards event author with parent event points, upvotes and anteups" do
      @actor = create(:user, name: "Some user")
      @rule = create(:rule_with_award)
      @event = create(:event_determined, rule: @rule)
      @reply = create(:event_determined, parent: @event)
      upvote = create(:upvote, applies_to: @event)
      anteup = create(:anteup, applies_to: @event)
      award = Award.create_award(@actor, @reply)

      sum = upvote.value + anteup.value + @event.rule.award_value
      expect(award.applies_to).to eq(@reply)
      expect(award.actor).to eq(@actor)
      expect(award.value).to eq(sum)
      # check if anteups are fullfilled?
    end
  end
end
