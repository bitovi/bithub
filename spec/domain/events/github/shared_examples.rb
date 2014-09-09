require 'domain/events/spec_helper.rb'

describe Events::Github do

  shared_examples_for "every github event" do
    it_should_behave_like "every event"

    it "has common github event attributes" do
      expect(payload.event_id).to be # String or Integer
      expect(payload.actor).to be_a(Hash)
      expect(payload.repo).to be_a(Hash)
      expect(payload.repo_name).to be_a(String)
      expect(payload.actor).to be_a(Hash)
      expect(payload.actor_id).to be_a(Integer)
      expect(payload.actor_login).to be_a(String)
      expect(payload.actor_avatar_url).to be_a(String)
      expect(payload.origin_ts).to be_a(Time)
    end
  end

  shared_examples_for "every github comment event" do
    it "has common github comment event attributes" do
      expect(payload.comment).to be_a(Hash)
      expect(payload.body).to be_a(String)
      expect(payload.html_url).to be_a(String)
      expect(payload.number).to be_a(Integer)
      expect(payload.state).to be_a(String)
    end
  end

  shared_examples_for "every github event with refs" do
    it "has refs attributes" do
      expect(payload.ref_type).to be_a(String)
      expect(payload.ref).to be_a(String)
    end
  end

  shared_examples_for "every github event with labels" do
    it "has lablel attributes" do
      expect(payload.labels).to be_a(Array)
      expect(payload.label_names).to be_a(String)
    end
  end

  shared_examples_for "every github issues or pull requests event" do
    it "has refs attributes" do
      expect(payload.html_url).to be_a(String)
      expect(payload.number).to be_a(Integer)
      expect(payload.state).to be_a(String)
      expect(payload.action).to be_a(String)
    end
  end

end
