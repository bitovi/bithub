require 'domain/spec_helper'

describe Determination do

  describe "#determine_feed" do
    it "determines a feed" do
      event = build(:event, props: {feed: 'github'})        
      event.determine_feed
      feed = Tag.find_by_name(event.props[:feed])
      expect(event.feed).to eq(feed)
    end
  end

  describe "#determine_category" do
    it "determines a category" do
      event = build(:event, props: {category: 'code'})        
      event.determine_category
      category = Tag.find_by_name(event.props[:category])
      expect(event.category).to eq(category)
    end
  end

  describe "#determine_rule" do
    it "determines a rule" do
      create(:rule, required_tags: %w(canjs code github))
      event = build(:event, tag_list: %w(canjs code github))        
      event.determine_rule
      rule = Rule.best_match(event.tag_list)
      expect(event.rule).to eq(rule)
    end
  end

  describe "#determine_tags" do

    before :all do
      @tags = [Tag.create({:name => 'foo'}),
               Tag.create({:name => 'bar'}),
               Tag.create({:name => 'github'}),
               Tag.create({:name => 'canjs', :aliases => ['can_js']}),
               Tag.create({:name => 'javascriptmvc'}),
               Tag.create({:name => 'feature', :aliases => ['enhancement', 'feature']}),
              ]
    end

    after :all do
      @tags.each {|t| t.destroy}
    end
    
    it "determines tags from props" do
      event = build(:event, props: {category: 'code', project: 'canjs', feed: 'github', tags: %w(foo bar)})
      event.determine_tags
      event.tag_list.should =~ %w(canjs github foo bar)
    end
    it "determines tags from event content" do
      event = build(:event, title: 'Foo canjs', body: 'Lorem ipsum javascriptmvc ...', props: {})
      event.determine_tags
      event.tag_list.should =~ %w(canjs javascriptmvc)
    end
    it "determines tags from labels" do
      event = build(:event, props: {labels: ['enhancement']})
      event.determine_tags
      event.tag_list.should =~ %w(feature)
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
