require 'celluloid/test'
require 'spec_helper'
require 'services/crawler/error_persistor'

describe ErrorPersistor do
  describe '#new' do
    before do
      @x = StandardError.new('something happen!')
      @p = ErrorPersistor.new(@x, 8)
    end

    it 'establishes a connection to the db' do
      expect(@p.error).to eq @x
    end

    it 'stores the error in the database' do
      expect do
        @p.persist
      end.to change{@p.errors.all.count}.by(1)
    end
  end
end
