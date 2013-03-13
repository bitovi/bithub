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


describe Stake do

  before :each do
    create(:rule)
    @actor = create(:user, name: "Some user")
    @event = create(:event_determined)
  end

  describe ".create_stake" do
    it "places stake on event" do 
      stake_value = 25
      stake = Stake.create_stake(@actor, @event, stake_value)
      expect(stake.applies_to).to eq(@event)
      expect(stake.actor).to eq(@actor)
      expect(stake.value).to eq(stake_value)
      expect(stake.fullfilled).to eq(false)
    end
  end

  describe ".fullfill_stakes" do
    it "sets fullfill to true on stakes belonging to an event" do 
      stake_value = 25
      @event2 = create(:event_determined)
      stake = Stake.create_stake(@actor, @event, stake_value)
      stake2 = Stake.create_stake(@actor, @event2, stake_value)
      Stake.fullfill_by_event(@event)
      expect(stake.reload.fullfilled).to eq(true)
      expect(stake2.reload.fullfilled).to eq(false)
    end
  end

end

describe Award do

  describe ".create_award" do
    it "awards event author with parent event points, upvotes and stakes" do
      @rule = create(:rule_with_award)
      @event = create(:event_determined, rule: @rule)
      @reply = create(:event_determined, parent: @event)
      upvote = create(:upvote, applies_to: @event)
      stake = create(:stake, applies_to: @event)
      award = Award.create_award(@actor, @reply)

      sum = upvote.value + stake.value + @event.rule.award_value
      expect(award.applies_to).to eq(@reply)
      expect(award.actor).to eq(@actor)
      expect(award.value).to eq(sum)
      # check if stakes are fullfilled?
    end
  end
end

<<-COMMENT
  describe ".donate" do
    it "transfers points from actor to author of event" do
      donation = 25
      activity = Activity.donate(@actor, @event, donation)
      expect(activity.identificator).to eq('donation')
      expect(activity.applies_to).to eq(@event)
      expect(activity.actor).to eq(@actor)
      expect(activity.value).to eq(donation)
      expect(activity.fullfilled).to eq(true)
    end
  end
end
COMMENT
