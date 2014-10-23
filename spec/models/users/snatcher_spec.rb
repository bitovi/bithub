require 'rails_helper'

RSpec.describe Users::Snatcher, :type => :domain do

  before do
    @veljko = FactoryGirl.create(:user, name: 'Veljko')
    @nikica = FactoryGirl.create(:user, name: 'Nikica')
    @mihael = FactoryGirl.create(:user, name: 'Mihael')
  end

  subject(:snatcher) { Users::Snatcher.new(@nikica, @veljko) }

  describe '#snatch_entities' do
    it 'snatches the entities from a user by updating the author field' do
      e1 = FactoryGirl.create(:determined_entity, title: 'First!', author: @veljko)
      e2 = FactoryGirl.create(:determined_entity, title: 'Second?', author: @veljko)

      expect{snatcher.snatch_entities}.to change{@nikica.entities.count}.from(0).to(2)
      expect(@veljko.entities.count).to eql(0)
    end
  end

end
