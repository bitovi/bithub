require 'rails_helper'
require 'models/filter'

RSpec.describe Filter, type: :model do

  describe '#sorted_in_application_order' do
    it 'sorts the filters in order of their application (first approving and then blocking)' do

      f1 = Filter.create(action: 'approve')
      f2 = Filter.create(action: 'block')
      f3 = Filter.create(action: 'approve')
      f4 = Filter.create(action: 'block')
      f5 = Filter.create(action: 'approve')

      expect(Filter.sorted_in_application_order.all).to eq([f1, f3, f5] + [f2, f4])
    end
  end

  describe '#validate_action_value' do
    it 'validates the two possible states of the filter' do
      e = FactoryGirl.create(:embed)
      expect do
        e.filters.create!(action: 'non_existent')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end
