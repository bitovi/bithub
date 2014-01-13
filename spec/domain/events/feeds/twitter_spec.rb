describe Events::Payload do

  shared_examples_for "every twitter event" do
    it_should_behave_like "every event"
  end

  describe "#initialize" do
    context "Twitter" do

      context "StatusEvent (Tweet)" do
        let(:payload) { build_payload('twitter','status_event') }

        it_should_behave_like "every twitter event"
        it "creates Payload object with mapping methods" do
          expect(payload.origin_id).to be_a(Integer)
          expect(payload.text).to be_a(String)
          expect(payload.user).to be_a(Hash)
          expect(payload.origin_author_id).to be_a(Integer)
          expect(payload.origin_author_name).to be_a(String)

          #expect(payload.html_url).to be_a()
          #expect(payload.retweeted_status).to be_a()
          #expect(payload.original_tweet_id).to be_a()
          #expect(payload.retweet?).to be_a()
        end        
      end

      context "FollowEvent" do
        let(:payload) { build_payload('twitter','follow_event') }
        
        it_should_behave_like "every twitter event"
        it "creates Payload object with mapping methods" do
          expect(payload.source).to be_a(Hash)
          expect(payload.source_id).to be_a(Integer)
          expect(payload.source_screen_name).to be_a(String)
          expect(payload.target).to be_a(Hash)
          expect(payload.target_id).to be_a(Integer)
          expect(payload.target_screen_name).to be_a(String)
        end            
      end

    end
  end
end
