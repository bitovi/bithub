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

    context "when grouping forum event" do

      before :each do
        @starter = {
          title: "Thread starter",
          url: "http://forums/thread",
          origin_date: Date.today,
          origin_ts: Time.now,
          props: {
            feed: "forums",
            category: "question",
            tags: ["forums", "questions"]
          }
        }
        @reply_1 = {
          title: "Thread reply no.1",
          url: "http://forums/thread#1",
          origin_date: Date.today,
          origin_ts: Time.now,
          props: {
            feed: "forums",
            category: "comment",
            tags: ["forums"]
          }
        }
        @reply_2 = {
          title: "Thread reply no.2",
          url: "http://forums/thread#2",
          origin_date: Date.today,
          origin_ts: Time.now,
          props: {
            feed: "forums",
            category: "comment",
            tags: ["forums"]
          }
        }
        @other = {
          title: "Other thread",
          url: "http://forums/other-thred",
          origin_date: Date.today,
          origin_ts: Time.now,
          props: {
            feed: "forums",
            category: "question",
            tags: ["forums", "questions"]
          }
        }
      end

      it "without hashtag in url should be thread starter (without children)" do
        starter = Event.new(@starter).group_if_forum_reply
        expect(starter.parent).to eql(nil)
      end

      it "without hashtag in url should be thread starter (with 2 children events)" do
        Event.new(@reply_1).save
        Event.new(@reply_2).save
        Event.new(@other).save
        starter = Event.new(@starter).group_if_forum_reply
        starter.save
        expect(starter.children.count).to eql(2)
      end
      
    end

  end
end
