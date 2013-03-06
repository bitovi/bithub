require 'spec_helper'
require 'digest/md5'

describe Event do

  context "upon creation" do
    before :each do
      create(:rule)
    end

    it "raises an error on save! b/c there is no feed or category" do
      generic_event = build(:github_issue)
      expect{generic_event.save!}.to raise_error
    end

    it "determines tags" do
      generic_event = build(:github_issue).determine_tags
      another_one = build(:github_issue)
      expect(generic_event.tag_list).to eq(another_one.props[:tags])
    end

    it "determines a feed" do
      generic_event = build(:github_issue).determine_feed
      feed = Tag.find_or_create(generic_event.props[:feed])
      expect(generic_event.feed).to eql(feed)
    end

    it "determines a category" do
      generic_event = build(:github_issue).determine_category
      category = Tag.find_or_create(generic_event.props[:category])
      expect(generic_event.category).to eql(category)
    end
    
    it "determines a rule" do
      generic_event = build(:github_issue).determine_rule
      rule = Rule.best_match(generic_event.props[:tags])
      expect(generic_event.rule).to eql(rule)
    end

    it "tries to find an author, and if there is none, creates a dummy one"

    context "when grouping forum events" do
      before :each do
        @starter = build(:forum_thread_starter)
        @reply1 = build(:forum_child)
        @reply2 = build(:forum_child)
      end

      it "without hashtag in url should be thread starter (without children)" do
        @starter.whole_chain.save!
        expect(@starter.parent).to be_nil
      end

      it "without hashtag in url should be thread starter (with 2 children events)" do
        @starter.whole_chain.save!
        @reply1.whole_chain.save!
        @reply2.whole_chain.save!
        # puts @starter.inspect.to_yaml
        # puts @reply1.inspect.to_yaml
        # puts @reply2.inspect.to_yaml
        expect(@starter.children.count).to eql(2)
      end
    end
  end
end
