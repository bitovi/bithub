require 'rails_helper'

RSpec.describe User, :type => :model do
  describe "#score" do

    before :each do
      @rule = FactoryGirl.create(:scoring_rule, authorship_value: 30, award_value: 10, upvote_value: 5)
      @author = FactoryGirl.create(:user, name: "Nikica", props: {})
      @actor = FactoryGirl.create(:user, name: "Veljko", props: {})
    end

    after :all do
      Identity.delete_all
    end

    it "should calculate total authorship points" do
      entity = FactoryGirl.create(
        :determined_entity,
        scoring_rule: @rule,
        title: "Event in user_spec, testing #score from authorship"
      )
      entity.author = @author
      expect(@author.reload.authored_entities_total).to eq 30
    end

    it "should calculate total upvote points" do
      entity = FactoryGirl.create(:determined_entity, scoring_rule: @rule, title: "Event in user_spec, testing #score from upvotes")
      entity.author = @author # overwrite one created by trait

      Upvote.create actor: @actor, applies_to: entity, value: 5
      Award.create actor: @actor, applies_to: entity, value: 10
      expect(@author.upvotes_total).to eq 5
    end

    it "should calculate total award points" do
      entity = FactoryGirl.create(:determined_entity, scoring_rule: @rule, title: "Event in user_spec, testing #score from awards")
      entity.author = @author # overwrite one created by trait

      Upvote.create actor: @actor, applies_to: entity, value: 5
      Award.create actor: @actor, applies_to: entity, value: 10
      expect(@author.awards_total).to eq 10
    end

    it "should calculate total points" do
      entity = FactoryGirl.create(:determined_entity, scoring_rule: @rule, title: "Event in user_spec, testing total #score")
      entity.author = @author # overwrite one created by trait

      Upvote.create actor: @actor, applies_to: entity, value: 5
      Award.create actor: @actor, applies_to: entity, value: 10
      expect(@author.reload.score).to eq (30+10+5)
    end
  end

  describe "#collect_authored_entities" do
    it "collects all entities with matching props -> origin_author_id"
  end
end
