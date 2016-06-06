require 'spec_helper'
require 'supervisors/brand'
require 'supervisors/node_types/node_types'
require_relative 'support/service_supervisor_mock'

describe Supervisors::Brand do
  before { Celluloid.boot }
  after { Celluloid.shutdown }
  
  let(:config) do
    JSON.parse(File.read('spec/support/responses/configurator/test_user_config.json'), symbolize_names: true)
  end

  let(:brand_sup_parent_node) do
    SupervisionNode.from_message({
      main: { wassap: 'notin' }
    })
  end

  let(:target) do
    SupervisionNode.from_message({
      main: { qua: 'wat' },
      brand: { id: 42, name: 'my_brand' },
      hub: { id: 17, name: 'my_hub' }
    })
  end

  describe '#stop_hub_supervisor' do
    it 'starts the designated hub supervisor' do
      brand_sup = Supervisors::Brand.new(brand_sup_parent_node, NodeTypes::BrandInfo.new(42, 'foo'))

      expect do
        brand_sup.handle_cmd(target, :start)
      end.to change { brand_sup.children.size }.from(0).to(1)
    end

    it 'stops the designated hub supervisor' do
      brand_sup = Supervisors::Brand.new(brand_sup_parent_node, NodeTypes::BrandInfo.new(42, 'foo'))
      brand_sup.boot(config.fetch(:brands).first)

      expect do
        brand_sup.handle_cmd(target, :stop)
      end.to change { brand_sup.children.size }.from(2).to(1)
    end
  end
end
