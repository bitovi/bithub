require 'spec_helper'
require 'supervisors/owner_data'
require 'supervisors/node_types/node_types'

describe OwnerData do
  describe '#initialize' do
    it 'constructs the owner data structure form brand, embed and service attributes' do
      od = OwnerData.new(1, 'a_brand', 11, 'an_embed', 111, 'github', 'repo', {})
      expect(od.brand).to be_an_instance_of NodeTypes::BrandInfo
      expect(od.embed).to be_an_instance_of NodeTypes::EmbedInfo
      expect(od.service).to be_an_instance_of NodeTypes::ServiceInfo
    end
  end
end
