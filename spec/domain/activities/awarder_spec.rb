require 'domain/spec_helper'

RSpec.describe Activities::Awarder, :type => :domain do

  let(:actor) { FactoryGirl.create(:user) }
  let(:entity) { FactoryGirl.create(:determined_entity) }
  subject(:awarder) { Activities::Awarder.new(actor, entity) }

  describe "#provided_strategy" do
    context "when strategy has not been provided" do
      it "responds with the default strategy" do
        expect(awarder.provided_strategy).to eq :double_upvote_value
      end
    end

    context "when strategy has been provided" do
      it "responds with the provided strategy" do
        expect(awarder.provided_strategy(strategy: :rule_based_value)).to eq :rule_based_value
      end
    end
  end

  describe "#valid_strategy?" do
    it "rejects unknown strategies" do
      expect(awarder.valid_strategy?(:nonsense)).to eq nil
    end

    it "confirms known strategies" do
      expect(awarder.valid_strategy?(:rule_based_value)).to eq :rule_based_value
    end
  end

  describe "#award" do
    it "responds with a created award based on strategy and provided actor and entity"
    it "responds with nil if the award could not be provided"
  end

  describe "#double_upvote_value" do
    it "responds with an award value that is equal to doubled total upvotes" do
      e = FactoryGirl.create(:determined_entity)
      FactoryGirl.create(:upvote, actor: actor, value: 7, applies_to: e)

      expect(Activities::Awarder.new(actor, e).double_upvote_value).to eq 14
    end
  end

  describe "#double_parents_upvote_value" do
    it "responds with an award value that is equal to doubled total upvotes of entity's parent entity" do
      p = FactoryGirl.create(:determined_entity)
      FactoryGirl.create(:upvote, actor: actor, value: 7, applies_to: p)

      e = FactoryGirl.create(:determined_entity, parent: p)
      FactoryGirl.create(:upvote, actor: actor, value: 3, applies_to: e)

      expect(Activities::Awarder.new(actor, e).double_parents_upvote_value).to eq 14
    end
  end

  describe "#rule_based_value" do
    it "responds with an award value that is specified by a scoring rule that is associated to the entity"
  end
end
