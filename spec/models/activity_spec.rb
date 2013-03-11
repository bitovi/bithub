require 'spec_helper'

describe Activity do

  context "upon creation" do
    before :each do
      create(:rule)
      @actor = create(:user, name: "Actor")
      @event = create(:event_determined)
      @event2 = create(:event_determined)
    end

    describe "#upvote" do
      it "upvotes event" do
        activity = Activity.upvote(@actor, @event)
        expect(activity.identificator).to eq('upvote')
        expect(activity.applies_to).to eq(@event)
        expect(activity.actor).to eq(@actor)
        expect(activity.value).to eq(@event.rule['upvote_value'])
        expect(activity.fullfilled).to eq(true)
        #expect(@event.reload.author.events_upvoted).to include(activity.applies_to)
      end
    end

    describe "#place_stake" do
      it "places stake on event" do 
        stake_value = 25
        activity = Activity.place_stake(@actor, @event, stake_value)
        expect(activity.identificator).to eq('stake')
        expect(activity.applies_to).to eq(@event)
        expect(activity.actor).to eq(@actor)
        expect(activity.value).to eq(stake_value)
        expect(activity.fullfilled).to eq(false)
      end
    end

    describe "#award" do
      it "awards event author with parent event points, upvotes and stakes" do
        @rule = create(:rule_with_award)
        @event = create(:event_determined, rule: @rule)
        @reply = create(:event_determined, parent: @event)
        upvote = create(:activity_upvote, applies_to: @event)
        stake = create(:activity_stake, applies_to: @event)
        activity = Activity.award(@actor, @reply)

        sum = upvote.value + stake.value + @event.rule.award_value
        expect(activity.identificator).to eq('award')
        expect(activity.applies_to).to eq(@reply)
        expect(activity.actor).to eq(@actor)
        expect(activity.value).to eq(sum)
        expect(activity.fullfilled).to eq(true)
        # check if stakes are fullfilled?
      end
    end

    describe "#fullfill_stakes" do
      it "sets fullfill to true on stakes" do 
        stake_value = 25
        activity = Activity.place_stake(@actor, @event, stake_value)
        activity2 = Activity.place_stake(@actor, @event2, stake_value)
        Activity.fullfill_stakes(@event)
        expect(activity.reload.fullfilled).to eq(true)
        expect(activity2.reload.fullfilled).to eq(false)
      end
    end

    describe "#donate" do
      it "transfers points from actor to author of event" do
        donation = 25
        activity = Activity.donate(@actor, @event, donation)
        expect(activity.identificator).to eq('donate')
        expect(activity.applies_to).to eq(@event)
        expect(activity.actor).to eq(@actor)
        expect(activity.value).to eq(donation)
        expect(activity.fullfilled).to eq(true)
      end
    end

  end
end
    
