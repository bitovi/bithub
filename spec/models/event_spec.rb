require 'spec_helper'

describe Event do

  context "upon creation" do
    let(:event_hash) {
        som = {
          title: "raised issue #7",
          body: "I'm the man, and I raised an issue.",
          url: "http://github.com/bitovi/canjs/issues/7",
          origin_date: Date.today,
          origin_ts: Time.now,
          props: {
            feed: "github",
            type: "issues_event",
            category: "issue"
          }
        }
    }

    it "assigns the attrs propertly" do
      new_event = Event.new(@event_hash)
      expect(new_event)
    end

    it "determines a feed" do
      new_event = Event.new(@event_hash).determine_feed.save
      feed = Tag.find_or_create({:name => @event_hash.props.feed})
      expect(new_event.feed).to eql(feed)
    end

    it "determines a category"
    it "determines a rule"
  end
end
