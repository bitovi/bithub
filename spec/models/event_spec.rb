require 'spec_helper'
require 'digest/md5'

describe Event do

  context "upon creation" do
    before :each do
      create(:rule)
    end

    it "raises an error on save! b/c there is no feed / category / tags / rules applied" do
      generic_event = build(:event)
      expect{generic_event.save!}.to raise_error
    end

    it "determines feed, category, rule and tags" do
      generic_event = build(:event)
      generic_event.whole_chain
      generic_event.save!
      feed = Tag.find_or_create(generic_event.raw_json[:feed])
      category = Tag.find_or_create(generic_event.raw_json[:category])
      rule = Rule.best_match(generic_event.raw_json[:tags])

      expect(generic_event.feed).to eq(feed)
      expect(generic_event.category).to eq(category)
      expect(generic_event.rule).to eq(rule)
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
        expect(@starter.children.count).to eql(2)
      end
    end
  end
end
