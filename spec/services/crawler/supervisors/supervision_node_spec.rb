require 'spec_helper'
require 'services/crawler/supervisors/supervision_node'

describe SupervisionNode do
  let(:msg) do
    {
      brand: { id: 1501, name: 'bitovi' },
      main: { watever: 'main' },
      service: { id: 3396, feed_name: 'github', type_name: 'repo', config: {}},
      hub: { id: 2452, name: 'code' }
    }
  end

  before do
    @s_node = SupervisionNode.new(
      @e_node = SupervisionNode.new(
        @b_node = SupervisionNode.new(
          @m_node = SupervisionNode.new(
            nil, @root = NodeTypes::MainInfo.new
          ), @bi = NodeTypes::BrandInfo.new(1501, 'bitovi')
        ), @ei = NodeTypes::HubInfo.new(2452, 'code')
      ), @si = NodeTypes::ServiceInfo.new(3396, 'github', 'repo', {})
    )
  end

  describe '.nodes_from_message' do
    it 'transforms the message into an ordered array of NodeTypes' do
    nodes = SupervisionNode.nodes_from_message(msg)

    expect(nodes).to eq([
      NodeTypes::MainInfo.from_message(msg[:main])\
      , NodeTypes::BrandInfo.from_message(msg[:brand])\
      , NodeTypes::HubInfo.from_message(msg[:hub])\
      , NodeTypes::ServiceInfo.from_message(msg[:service])
    ])
    end
  end
  
  describe '.tree_from_nodes' do
    it 'given a list of NodeTypes it recursively traverses it, creating SupervisionNode nodes' do
      nodes = SupervisionNode.nodes_from_message(msg)

      leaf = SupervisionNode.tree_from_nodes(nodes)
      expect(leaf.node).to eq NodeTypes::ServiceInfo.new(3396, 'github', 'repo', {})
      expect(leaf.string_path).to eq %w(main b/1501 e/2452 s/3396)
      expect(leaf.brand.to_s).to eq 'b/1501'
      expect(leaf.hub.to_s).to eq 'e/2452'
      expect(leaf.service.to_s).to eq 's/3396'
      expect(leaf.actor_name).to eq 'main->b/1501->e/2452->s/3396'.to_sym
    end
  end
  
  describe '#string_path' do
    it 'recursively calculates the current path, returning the string representation of nodes' do
      expect(@s_node.string_path).to eq %w(main b/1501 e/2452 s/3396)
    end
  end
  
  describe '#path' do
    it 'recursively calculates the current path, returning the unprocessed nodes' do
      expect(@s_node.path).to eq [@root, @bi, @ei, @si]
    end
  end
  
  describe '#depth' do
    it 'calculates the tree-depth of the current node' do
      expect(@s_node.depth).to eq 3
    end
  end

  describe '#rootless' do
    it 'recursively calculates the current path, omitting the root node' do
      expect(@s_node.rootless).to eq [@bi, @ei, @si]
    end
  end

  describe '#root?' do
    it 'determines whether a given node is the root node' do
      expect(@m_node.root?).to be_truthy
    end
  end

  describe '#actor_name' do
    it 'converts the current path to an array of strings that identify an actor' do
      expect(@s_node.actor_name).to eq :'main->b/1501->e/2452->s/3396'
    end
  end

  describe '#brand_info' do
    it 'finds the brand information in the tree' do
      expect(@s_node.brand_info).to eq NodeTypes::BrandInfo.new(1501, 'bitovi')
    end
  end

  describe '#hub_info' do
    it 'finds the hub information in the tree' do
      expect(@s_node.hub_info).to eq NodeTypes::HubInfo.new(2452, 'code')
    end
  end

  describe '#service_info' do
    it 'finds the service information in the tree' do
      expect(@s_node.service_info).to eq NodeTypes::ServiceInfo.new(3396, 'github', 'repo', {})
    end
  end
end
