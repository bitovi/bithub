require 'rails_helper'
require 'models/embed'

RSpec.describe Embed, :type => :model do

  describe '#moderating_filter' do
    it 'finds the associated moderating filter among all filters' do
      e = Embed.create(:name => 'test embed')
      f = (e.filters.create(:is_conj => true, :classification => 'moderating'))
      expect(e.moderating_filter).to eq f
    end
  end
  
  describe '#blocking_filter' do
    it 'finds the associated blocking filter among all filters' do
      e = Embed.create(:name => 'test embed')
      f = (e.filters.create(:is_conj => true, :classification => 'blocking'))
      expect(e.blocking_filter).to eq f
    end
  end
end
