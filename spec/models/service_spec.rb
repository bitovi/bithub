require 'rails_helper'
require 'models/service'

RSpec.describe Service, :type => :model do

  describe '#valid?' do
    it 'delegates validation to the ServiceConfig model' do
      s = Service.new({
        embed_id: 7,
        feed_name: 'twitter',
        type_name: 'followers',
        config: {
          fruit: %w(apple and banana)
        }
      })

      expect(s.valid?).to be_falsey
    end
  end

end
