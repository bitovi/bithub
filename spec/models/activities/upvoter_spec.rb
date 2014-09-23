require 'models/spec_helper'

RSpec.describe Activities::Upvoter, :type => :domain do

  it "should create upvotes based on scoring rules" do
    actor = FactoryGirl.create(:user, name: "Nikica")
    sr = FactoryGirl.build(:scoring_rule, upvote_value: 10)
    entity = FactoryGirl.build(:determined_entity, scoring_rule: sr, title: "Entity in Awarder specs")
  
    upvote = Activities::Upvoter.new(actor, entity).upvote

    expect(upvote.value).to eql(10)
    expect(upvote).to be_an_instance_of Upvote
  end
end
