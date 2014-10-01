require 'spec_helper'
require 'andand'
require 'models/services/service_config'

describe Services::ServiceConfig do

  describe '#terms' do
    it 'plucks terms out of @data if they\'re present' do
      sc = Services::ServiceConfig.new({'terms' => %w(some terms)}, 'doesn_matter')
      expect(sc.terms).to eq(%w(some terms))
    end

    it 'returns an empty array if there are no terms in the config' do
      sc = Services::ServiceConfig.new({'terms' => nil}, 'doesn_matter')
      expect(sc.terms).to eq([])
    end
  end
  
end
