require 'spec_helper'
require 'services/crawler/streamer/channel'

describe Channel do
  Message = Struct.new(:title, :body)

  let(:channel) do
    Channel.new('nikica', %w(canjs))
  end

  describe "#interested?" do
    it "tells the caller if the current channel is interested in an incoming message" do
      dummy_msg_obj = Message.new((t = 'new tweet'), (b = 'with canjs body'))
      dummy_msg_hash = Message.new((t = 'new commit'), (b = 'reimplemented jquerypp event system'))

      expect(channel.interested? dummy_msg_obj).to eq true
      expect(channel.interested? dummy_msg_hash).to eq false
    end
  end

  describe "#target_text" do
    context "when the incoming message is a custom object" do
      it "textualizes the object by concating results of invoked methods" do
        dummy_msg_obj = Message.new((t = 'new tweet'), (b = 'with canjs body'))

        expect(channel.target_text(dummy_msg_obj, %i(title body))).to eq(t+b)
      end
    end

    context "when the incoming message is an instance of Hash" do
      it "textualizes the hash by concating given attrs" do
        dummy_msg_hash = Hash[:title, (t = 'new commit'), :body, (b = 'changed canjs implementation')]
        expect(channel.target_text(dummy_msg_hash, %i(title body))).to eq(t+b)
      end
    end
  end
end
