require_relative 'support/spec_helper'

describe User do
  describe "#score" do
    before :all do
      @rule = create(:scoring_rule, authorship_value: 33, award_value: 0, upvote_value: 11)
      @author = create(:user, name: "Nikica")
      @actor = create(:user, name: "Veljko")
    end

    after :all do
      @rule.destroy
      @author.destroy
      @actor.destroy
    end

    it "should calculate total authorship points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing #score from authorship")
      expect(@author.reload.authored_entities_total).to eq(33)
    end

    it "should calculate total upvote points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing #score from upvotes")
      Upvote.create_based_on_rule(@actor, event)
      expect(@author.upvotes_total).to eq(11)
    end

    it "should calculate total award points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing #score from awards")
      Upvote.create_based_on_rule(@actor, event)
      Award.create_based_on_strategy(@actor, event, strategy: :double_the_upvotes)
      expect(@author.awards_total).to eq(11*2)
    end

    it "should calculate total points" do
      event = create(:entity_determined, scoring_rule: @rule, author: @author, title: "Event in user_spec, testing total #score")
      Upvote.create_based_on_rule(@actor, event)
      Award.create_based_on_strategy(@actor, event, strategy: :double_the_upvotes)
      expect(@author.reload.score).to eq(11+11*2+33)
    end
  end


  describe "#collect_authored_entities" do
    it "collects all entities with matching props -> origin_author_id" do
      user = build(:user, name: 'Floppy', email: 'floppy@qua.wat')
      user.identities << build(:identity, uid: 123456789, provider: 'twitter')
      user.identities << build(:identity, uid: 987654321, provider: 'github')
      user.save!

      e1 = create(:entity_determined, title: "First event", props: { origin_author_id: 123456789 })
      e2 = create(:entity_determined, title: "Second event", props: { origin_author_id: 987654321 })
      e3 = create(:entity_determined, title: "Third event", props: { origin_author_id: 123456789 })

      entities = [e1, e2, e3]
      user.collect_authored_entities
      user.reload.entities.should =~ entities
    end
  end
end
