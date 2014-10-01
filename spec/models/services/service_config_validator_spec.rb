require 'spec_helper'
require 'models/services/service_config_validator'

describe ServiceConfigValidator do
  
  describe '#has?' do
    it 'checks if the config is a Hash' do
      scv = ServiceConfigValidator.new([:a_key, :a_value], 'doesn_matter')
      expect(scv.has?(:a_key)).to be_falsey
    end

    it 'checks if hash has the key' do
      scv = ServiceConfigValidator.new({:no_key => :no_value}, 'doesn_matter')
      expect(scv.has?(:a_key)).to be_falsey
    end

    it 'checks if the key is non-empty' do
      scv = ServiceConfigValidator.new({:a_key => ""}, 'doesn_matter')
      expect(scv.has?(:a_key)).to be_falsey
    end
  end
end
