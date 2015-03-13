require 'rails_helper'

describe Subscriptions::PolicyChecker do

  before :each do
    limits = {
      brands: 1,
      embeds_per_brand: 2,
      services_per_embed: 3,
      twitter_user_timeline: 1
    }

    @brand        = FactoryGirl.create :brand
    @embed        = FactoryGirl.create :embed, brand: @brand
    @plan         = FactoryGirl.create :plan, limits: limits
    @org          = FactoryGirl.create :organization, brands: [@brand]
    @subscription = FactoryGirl.create :subscription, plan: @plan, organization: @org
  end

  describe '#can_create_brand?' do
    it 'checks brand limit against current brand count' do
      checker = Subscriptions::PolicyChecker.new @subscription
      expect( checker.can_create_brand?(@org) ).to eq false
    end
  end

  describe '#can_create_embed?' do
    it 'checks embed limit against current embed count' do
      checker = Subscriptions::PolicyChecker.new @subscription
      expect( checker.can_create_embed?(@brand) ).to eq true
    end
  end

  describe '#can_create_service?' do
    it 'checks service limit per feed/type pair' do
      FactoryGirl.create :twitter_service, embed: @embed
      FactoryGirl.create :twitter_service, embed: @embed

      checker = Subscriptions::PolicyChecker.new @subscription
      expect( checker.can_create_service?(@embed, 'twitter', 'user_timeline') ).to eq false
    end

    it 'checks service limit against current service count' do
      FactoryGirl.create :github_service, embed: @embed
      FactoryGirl.create :twitter_service, embed: @embed

      checker = Subscriptions::PolicyChecker.new @subscription
      expect( checker.can_create_service?(@embed) ).to eq true
    end
  end

end
