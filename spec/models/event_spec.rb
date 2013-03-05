require 'spec_helper'

describe Event do

  context "upon creation" do

    before :each do
      @event_hash = {
        title: "raised issue #7",
        body: "I'm the man, and I raised an issue.",
        url: "http://github.com/bitovi/canjs/issues/7",
        origin_date: Date.today,
        origin_ts: Time.now,
        props: {
          feed: "github",
          type: "issues_event",
          category: "issue",
          tags: ["github", "issues_event", "issue"]
          }
      }
    end

    it "raises an error on save! b/c there is no feed or category" do
      expect{Event.new(@event_hash).save!}.to raise_error
    end

    it "determines a feed" do
      new_event = Event.new(@event_hash).determine_feed
      feed = Tag.find_or_create(@event_hash[:props][:feed])
      expect(new_event.feed).to eql(feed)
    end

    it "determines a category" do
      new_event = Event.new(@event_hash).determine_category
      category = Tag.find_or_create(@event_hash[:props][:category])
      expect(new_event.category).to eql(category)
    end
    
    it "determines a rule" do
      new_event = Event.new(@event_hash).determine_rule
      rule = Rule.best_match(@event_hash[:props][:tags])
      expect(new_event.rule).to eql(rule)
    end

    it "tries to find an author, and if there is none, creates a dummy one"
  end
end
