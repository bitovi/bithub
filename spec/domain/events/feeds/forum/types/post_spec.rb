describe Events::Feeds::Forum::Types::Post do

  describe "#initialize" do

    let(:payload) { build_payload('forum','post') }

    it_should_behave_like "every event"
    it "creates Payload object with mapping methods" do
      expect(payload.title).to be_a(String)
      expect(payload.body).to be_a(String)
      expect(payload.link).to be_a(String)
      expect(payload.subforum).to be_a(String)
      expect(payload.origin_author_name).to be_a(String)
      expect(payload.origin_timestamp).to be_a(Date)
    end    
  end
end
