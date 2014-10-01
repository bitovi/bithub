require 'rails_helper'

describe Identities::BrandIdentityConfig do
  
  describe '#subbuilder' do
    it 'finds the appropriate builder for the config' do
      bic = Identities::BrandIdentityConfig.new(
        {:oauth => {'doesnt' => 'matter'}},
        'facebook'
      )
      expect(bic.builder_class).to eq(Identities::Builders::Facebook)
    end
  end
end
