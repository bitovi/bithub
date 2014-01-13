describe Events::Payload do

  describe "#initialize" do
    context "Disqus" do

      context "Post" do
        let(:payload) { build_payload('disqus','post') }

        it_should_behave_like "every event"
        it "creates Payload object with mapping methods" do
          expect(payload.post_id).to be_a(Integer)
          expect(payload.thread).to be_a(String)
          expect(payload.title).to be_a(String)
          expect(payload.message).to be_a(String)
          expect(payload.url).to be_a(String)
          expect(payload.origin_author_name).to be_a(String)
          expect(payload.origin_timestamp).to be_a(Date)
        end        
      end

    end
  end
end
