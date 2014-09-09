require 'domain/spec_helper'

RSpec.describe Users::DuplicateInternalsCleaner, :type => :domain do

  before do
    @user = FactoryGirl.create(:user)
    @i1 = FactoryGirl.create(:internal, variant: 'linked_github', receiver: @user)
  end

  subject(:cleaner) { Users::DuplicateInternalsCleaner.new(@user) }

  describe '#duplicates' do
    it 'returns duplicate internals' do
      i2 = FactoryGirl.build(:internal, variant: 'linked_github', receiver: @user)
      i3 = FactoryGirl.build(:internal, variant: 'linked_twitter', receiver: @user)
      i2.save(:validate => false); i3.save(:validate => false)
      expect(cleaner.duplicates).to eq [i2]
    end
  end

  describe '#clean' do
    it 'returns a truthy value if there were duplicate internals' do
      i2 = FactoryGirl.build(:internal, variant: 'linked_github', receiver: @user)
      i2.save(:validate => false)
      expect(cleaner.clean).to be_truthy
    end

    it 'returns a falsey value if there were no duplicate internals' do
      expect(cleaner.clean).to be_falsey
    end
  end

end
