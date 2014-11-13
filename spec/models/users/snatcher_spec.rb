require 'rails_helper'

RSpec.describe Users::Snatcher, :type => :model do
  after(:all) { DatabaseCleaner.clean_with :truncation }

  describe '#snatch_entities' do
    it 'snatches the entities from a user by updating the author field' do
      @veljko = FactoryGirl.create(:user, name: 'Veljko')
      @nikica = FactoryGirl.create(:user, name: 'Nikica')

      FactoryGirl.create(:determined_entity, title: 'First!', author: @veljko)
      FactoryGirl.create(:determined_entity, title: 'Second?', author: @veljko)
  
      snatcher = Users::Snatcher.new(@nikica, @veljko)

      expect{snatcher.snatch_entities}.to change{@nikica.entities.count}.from(0).to(2)
      expect(@veljko.entities.count).to eql(0)
    end
  end
end
