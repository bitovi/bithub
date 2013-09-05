require 'spec_helper'

describe Award do
  describe ".create_with_strategy"
  describe ".total_value"
  describe ".double_upvote_value"
  describe ".thread_not_already_awarded"
end

    # before(:each) do
    #   @actor = create(:user, name: "Some user")
    #   @rule = create(:rule, award_value: 100)
    #   @event = create(:event_determined, rule: @rule)
    #   @reply = create(:event_determined, parent: @event)
    #   @upvote = create(:upvote, applies_to: @event)
    #   @anteup = create(:anteup, applies_to: @event)
    #   @award = Award.create({actor: @actor, applies_to_id: @reply, value: Award.double_upvote_value(@event)})
    # end

    # it "sets the actor" do
    #   expect(@award.actor).to eq(@actor)
    # end

    # it "sets the target event" do
    #   expect(@award.applies_to).to eq(@reply)
    # end

    # it "calculates and sets the total point value for the award" do
    #   sum = @upvote.value + @anteup.value + @event.rule.award_value
    #   expect(@award.value).to eq(sum)
    # end
