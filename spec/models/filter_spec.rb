require 'rails_helper'
require 'models/filter'

RSpec.describe Filter, :type => :model do

  describe '#classification_must_be_either_blocking_or_moderating' do
    it 'validates the two possible states of the filter' do

      e = FactoryGirl.create(:embed)

      expect do
        e.filters.create!(:classification => 'non_existent', :is_conj => true)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#all?' do
    it 'tells whether the queries are conjunctive' do
      f = FactoryGirl.build(:filter, :is_conj => true)
      expect(f.all?).to be_truthy
      expect(f.any?).to be_falsey
    end
  end

  describe "#any?" do
    it 'tells whether the queries are disjunctive' do
      f = FactoryGirl.build(:filter, :is_conj => false)
      expect(f.any?).to be_truthy
      expect(f.all?).to be_falsey
    end
  end

  describe "#detects?" do
    it 'tells whether it, when applied to entities, finds the provided entity' do
      pending 'todo'
    end
  end
end
