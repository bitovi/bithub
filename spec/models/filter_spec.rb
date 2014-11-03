require 'rails_helper'
require 'models/filter'

RSpec.describe Filter, type: :model do

  describe '#classification_type validator' do
    it 'validates the three possible states of the filter' do
      e = FactoryGirl.create(:embed)
      expect do
        e.filters.create!(classification: 'non_existent', is_conj: true)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#classification_filterable_combination validator' do

    it 'validates that a moderating/blocking filter\
      can only be associated to an embed' do
      e = FactoryGirl.create(:embed)
      s = FactoryGirl.create(:service, embed: e)
      expect do
        s.create_filter!(classification: 'moderating', is_conj: true)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'validates that a linking filter can only be associated to a service' do
      e = FactoryGirl.create(:embed)
      expect do
        e.filters.create!(classification: 'linking', is_conj: true)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#all?' do
    it 'tells whether the queries are conjunctive' do
      f = FactoryGirl.build(:filter, is_conj: true)
      expect(f.all?).to be_truthy
      expect(f.any?).to be_falsey
    end
  end

  describe '#any?' do
    it 'tells whether the queries are disjunctive' do
      f = FactoryGirl.build(:filter, is_conj: false)
      expect(f.any?).to be_truthy
      expect(f.all?).to be_falsey
    end
  end
end
