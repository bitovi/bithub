require 'rails_helper'
require 'models/embed'

RSpec.describe Embed, :type => :model do

  describe 'blocking_filter' do
    it 'finds the associated moderating filter among all filters' do

      e = Embed.create(:name => 'embed one')
      f = Filter.create(:is_conj => true)

      EmbedFilter.create({
        :classification => 'blocking',
        :filter => f,
        :embed => e
      })

      expect(e.blocking_filter).to be
    end

    it 'finds the associated blocking filter among all filters' do
      e = Embed.create(:name => 'embed one')
      f = Filter.create(:is_conj => true)

      EmbedFilter.create({
        :classification => 'moderating',
        :filter => f,
        :embed => e
      })

      expect(e.moderating_filter).to be
    end
  end
end
