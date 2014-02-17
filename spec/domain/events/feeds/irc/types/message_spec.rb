require 'domain/events/spec_helper.rb'

describe Events::Feeds::Irc::Types::Message do

  describe "#initialize" do

    message = {
      channel: '#canjs',
      nickname: 'veljko',
      message: 'foobar',
      ts: Time.now
    }

    let(:payload) { Events::Feeds::Irc::Types::Message.new(payload) }

    it_should_behave_like "every event"
    it "creates Payload object with mapping methods" do
      expect(payload.title).not_to be_empty
      expect(payload.message).not_to be_empty
      expect(payload.url).not_to be_empty
      expect(payload.origin_author_name).not_to be_empty
      expect(payload.origin_ts).to be_a(Time)
    end        

  end
end
