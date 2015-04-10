require 'rails_helper'
require 'models/filter'

RSpec.describe Filter, type: :model do

  describe '#validate_action_value' do
    it 'validates the two possible states of the filter' do
      e = FactoryGirl.create(:embed)
      expect do
        e.filters.create!(action: 'non_existent')
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end
