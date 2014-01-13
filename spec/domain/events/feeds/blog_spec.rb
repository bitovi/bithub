describe Events::Payload do

  describe "#initialize" do
    context "Blog" do

      context "Post" do
        let(:payload) { build_payload('blog','post') }
        
        it_should_behave_like "every event"
        it "creates Payload object with mapping methods" do
          expect(payload.title).to be_a(String)
          expect(payload.body).to be_a(String)
          expect(payload.link).to be_a(String)
          expect(payload.origin_timestamp).to be_a(Date)
        end    
      end
      
    end
  end
end
