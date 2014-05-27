require 'spec_helper'

describe Entity do

  before(:all) do
    import_tags
  end

  after(:all) do
    Entity.destroy_all
    Tag.destroy_all
  end

  context "upon creation" do

    describe "#save" do
      it "raises an error on save! b/c there is no feed / category / tags / rules applied" do
        generic_entity = FactoryGirl.build(:entity)
        expect{generic_entity.save!}.to raise_error
      end
    end

    describe ".has_an_attribute?" do
      context "symbol given" do
        it "confirms that the Entity model indeed has an attribute" do
          expect(Entity.has_an_attribute?(:title)).to be_true
        end

        it "denies that the Entity model has a non-existent attribute" do
          expect(Entity.has_an_attribute?(:budalas)).to be_false
        end
      end

      context "string given" do
        it "confirms that the Entity model indeed has an attribute" do
          expect(Entity.has_an_attribute?("title")).to be_true
        end

        it "denies that the Entity model has a non-existent attribute" do
          expect(Entity.has_an_attribute?("titles")).to be_false
        end
      end
    end

    describe "#thread" do
      it "fetches the entity itself wrapped in an array if there is no thread" do
        e = FactoryGirl.create(:github_issue, title: "Why is this happening?")
        e.thread.should =~ [e]
      end

      it "fetches the whole thread" do
        pe = FactoryGirl.create(:github_issue, title: "Why is this happening?")
        ce1 = FactoryGirl.create(:github_issue_comment, title: "I don't care.", parent: pe)
        ce2 = FactoryGirl.create(:github_issue_comment, title: "Wat? Qua?", parent: pe)
        pe.thread.should =~ ce1.thread
        expect(pe.thread.length).to eql(3)
      end
    end

    describe "#bump_thread" do
      it "updates the thread_updated_ts attribute for all entities in a thread" do
        pe = FactoryGirl.create(:github_issue, title: "Why is this happening?", origin_ts: Time.now+5)
        ce1 = FactoryGirl.create(:github_issue_comment, title: "I don't care.", parent: pe, origin_ts: Time.now+10)
        ce2 = FactoryGirl.create(:github_issue_comment, title: "Wat? Qua?", parent: pe, origin_ts: Time.now+15)

        ce2.bump_thread
        pe.reload.thread_updated_ts.should > pe.origin_ts
        ce1.reload.thread_updated_ts.should > ce1.origin_ts
        ce2.reload.thread_updated_ts.should == ce2.origin_ts
      end
    end

    describe "#cache_key" do
      before(:each) { @entity = FactoryGirl.create(:determined_entity, title: "Entity in entity_spec, testing #cache_key") }

      it "uses the id, updated_at and thread_updated_ts timestamps when they are present" do
        expect(@entity.reload.cache_key).to eq "entities/#{@entity.id}-#{@entity.updated_at.utc.to_s(:number)}-#{@entity.thread_updated_ts.utc.to_s(:number)}"
      end
    end
  end
end
