require 'rails_helper'
require 'models/service'

RSpec.describe Service, :type => :model do

  describe '#valid?' do
    it 'delegates validation to the ServiceConfig model' do

      s = Service.new({
        feed_name: 'twitter',
        type_name: 'followers',
        config: {
          fruit: %w(apple and banana)
        },
        embed: Embed.new({
          name: 'test-embed',
          brand: Brand.current
        })
      })

      expect(s.valid?).to be_falsey
    end
  end

end
