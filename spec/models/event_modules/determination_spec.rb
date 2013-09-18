require 'spec_helper'

describe Determination do

  describe "#determine_feed" do
    it "determines a feed" do
      event = build(:event_wo_feed)        
      event.determine_feed.save!
      feed = Tag.find_by_name(event.props['feed'])
      expect(event.feed).to eq(feed)
    end
  end

  describe "#determine_category" do
    it "determines a category" do
      event = build(:event_wo_category)        
      event.determine_category.save!
      category = Tag.find_by_name(event.props['category'])
      expect(event.category).to eq(category)
    end
  end

  describe "#determine_rule" do
    it "determines a rule" do
      event = create(:event_wo_rule)        
      event.determine_rule.save!
      rule = Rule.best_match(event.props[:tags])
      expect(event.rule).to eq(rule)
    end
  end

  describe "#determine_tags" do
    it "determines tags" do
      event = build(:event_wo_tags)
      event.determine_tags.save!
      tags = Tag.find_or_create_all_with_like_by_name(['some_feed','some_category','some_content_tag'])
      event.tags.should =~ tags
    end
  end

  describe "#determine_author" do
    context "when there is an author in the system" do

      before(:each) do
        @usr = create(:user, name: "Nikica")
        ident = create(:identity, uid: 456789, provider: "github", user: @usr)
        ident = create(:identity, uid: 123456, provider: "twitter", user: @usr)
      end

      it "associates it with a github event" do
        ghe = build(:github_issue, props: {feed: 'github', origin_author_id: 456789})
        ghe.determine_author.save!
        expect(ghe.author).to eq(@usr)
      end

      it "associates it with a twitter event" do
        twe = build(:twitter_tweet, props: {feed: 'twitter', origin_author_id: 123456})
        twe.determine_author.save!
        expect(twe.author).to eq(@usr)
      end
    end
  end

  describe "#clean_props_after_categorization" do
    it "should clean the props attribute from unecessary stuff"
  end
end
