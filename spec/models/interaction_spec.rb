require 'rails_helper'

RSpec.describe Interaction, type: :model do
  describe '#select_statement' do
    it 'constructs a select statement to pull out aggregated values'
  end

  describe '#group_statement' do
    it 'constructs a group-by statement to group by appropriate fields'
  end

  describe '#order_statement' do
    it 'constructs an order by statement'
  end
end
