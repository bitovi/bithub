require 'rails_helper'
require 'models/filter'

RSpec.describe Filter, :type => :model do

  describe '#any?' do
    it 'tells whether the queries are conjunctive' do
      f = FactoryGirl.build(:filter)
      expect(f.any?).to be_falsey
      expect(f.all?).to be_truthy
    end

    it 'tells whether the queries are disjunctive' do
      f = FactoryGirl.build(:filter, :is_conj => false)
      expect(f.any?).to be_truthy
      expect(f.all?).to be_falsey
    end
  end
end
