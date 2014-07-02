require 'domain/spec_helper'

RSpec.describe Users::EntitiesUnlinker, :type => :domain do

  before do
    @user = FactoryGirl.create(:user)
    @ghi = FactoryGirl.create(:identity, user: @user, provider: 'github', uid: 123456789)
    @twi = FactoryGirl.create(:identity, user: @user, provider: 'twitter', uid: 987654321)
    @tw_id = Users::IdentData.new(123456789, 'github')
    @gh_id = Users::IdentData.new(987654321, 'twitter')
    @e1 = FactoryGirl.create(:determined_entity, props: { origin_author_id: '987654321' })
    @e2 = FactoryGirl.create(:determined_entity, props: { origin_author_id: '123456789' })
    @o1 = FactoryGirl.create(:ownership, owner: @user, entity: @e1, ownership_type: :author)
    @o2 = FactoryGirl.create(:ownership, owner: @user, entity: @e2, ownership_type: :author)
  end

  describe "#unlink_entities" do

    it "removes ownerships for events that have a provided UID in props" do
      Users::EntitiesUnlinker.new(@gh_id, @user.id).unlink_authored_entities
      expect{@o1.reload}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "doesn't touch user's other ownerships" do
      Users::EntitiesUnlinker.new(@gh_id, @user.id).unlink_authored_entities
      expect(@o2.reload).to be
    end

    it "returns a falsy val if the user doesn't have the ident that's being unlinked" do
      unlinker = Users::EntitiesUnlinker.new(Users::IdentData.new(42, 'not'), @user.id)
      expect(unlinker.unlink_authored_entities).to be_nil
    end

    it "returns a truthy val if unlinking was successful" do
      unlinker = Users::EntitiesUnlinker.new(@gh_id, @user.id)
      expect(unlinker.unlink_authored_entities).to be
    end
  end

end
