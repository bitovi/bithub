describe Events::Payload do

  describe "#initialize" do
    context "Bithub" do

      context "Post" do
        let(:payload) { build_payload('bithub','post') }

        it_should_behave_like "every event"
        it "creates Payload object with mapping methods" do
          expect(payload.title).to be_a(Integer)
          expect(payload.url).to be_a(String)
          expect(payload.body).to be_a(String)
        end        
      end

    end
  end
end
