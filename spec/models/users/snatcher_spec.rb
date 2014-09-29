require 'models/spec_helper'

RSpec.describe Users::Snatcher, :type => :domain do

  before do
    @veljko = FactoryGirl.create(:user, name: 'Veljko')
    @nikica = FactoryGirl.create(:user, name: 'Nikica')
    @mihael = FactoryGirl.create(:user, name: 'Mihael')
  end

  subject(:snatcher) { Users::Snatcher.new(@nikica, @veljko) }

  describe '#snatch_entities' do
    it 'snatches the entities from a user by updating the author field' do
      e1 = FactoryGirl.create(:determined_entity, title: 'First!', author: @veljko)
      e2 = FactoryGirl.create(:determined_entity, title: 'Second?', author: @veljko)

      expect{snatcher.snatch_entities}.to change{@nikica.entities.count}.from(0).to(2)
      expect(@veljko.entities.count).to eql(0)
    end

  end

  describe "#snatch_actions" do
    it "snatches upvotes in which the user is an actor from the other user" do
      e = FactoryGirl.create(:determined_entity, title: 'Only', author: @mihael)
      u = FactoryGirl.create(:upvote, actor: @veljko, applies_to: e)
      expect{snatcher.snatch_actions}.to change{@nikica.upvotes_as_actor.count}.from(0).to(1)
      expect(@mihael.upvotes_as_actor.count).to eql 0
    end

    it "snatches awards in which the user is an actor from the other user" do
      e = FactoryGirl.create(:determined_entity, title: 'Only', author: @mihael)
      a = FactoryGirl.create(:award, actor: @veljko, applies_to: e)
      expect{snatcher.snatch_actions}.to change{@nikica.awards_as_actor.count}.from(0).to(1)
      expect(@mihael.awards_as_actor.count).to eql 0
    end
  end

  describe "#snatch_internals" do
    it "snatches internals from other user" do
      a = FactoryGirl.create(:internal, actor: @mihael, receiver: @veljko, value: 10)
      expect{snatcher.snatch_internals}.to change{@nikica.internals.count}.from(0).to(1)
      expect(@veljko.internals.count).to eql 0
    end
  end
end
