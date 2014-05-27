require 'spec_helper'

describe FeedConfigTagPlucker do

  describe "#tags_from_github" do
    it "plucks an org and repo names" do
      params = {"feed_name"=>"github", "config"=>{"repos"=>["neektza/dotfiles", "neektza/actor_demo"], "orgs"=>["KSET"]}}
      FeedConfigTagPlucker.new(params).tags_from_github.should =~ %w(dotfiles actor_demo kset)
    end
  end

  describe "#tags_from_meetup" do
    it "plucks the group name" do
      params = {"feed_name"=>"meetup", "config"=>{"groups"=>[{"id"=>"13140052", "name"=>"rubyzg"}, {"id"=>"10878382", "name"=>"ZgElixir"}], "terms"=>["materina", "neektza"]}}
      expect(FeedConfigTagPlucker.new(params).tags_from_meetup).to eq %w(rubyzg zg_elixir)
    end
  end

  describe "#tags_from_facebook" do
    it "plucks the page and group names" do
      params = {"feed_name"=>"facebook", "config"=>{"pages"=>[{"id"=>"487939194652299", "access_token"=>"123", "name"=>"Koryu Bujutsu Zagreb"}]}}
      expect(FeedConfigTagPlucker.new(params).tags_from_facebook).to eq %w(koryu_bujutsu_zagreb)
    end
  end

  describe "#tags_from_rss" do
    it "plucks the domain name as tag" do
      params = {"feed_name"=>"rss", "config"=>{"urls"=>["http://pltconfusion.com"]}}
      expect(FeedConfigTagPlucker.new(params).tags_from_rss).to eq %w(pltconfusion.com)
    end
  end

  describe "#tags_from_disqus" do
    it "plucks the forum name" do
      params = {"feed_name"=>"disqus", "config"=>{"forums"=>[{"id"=>"pltconfusion", "name"=>"PLT Confusion"}]}}
      expect(FeedConfigTagPlucker.new(params).tags_from_disqus).to eq %w(pltconfusion)
    end
  end

  describe "#tags_from_foursqare" do
    it "plucks the venue name"
  end

end
