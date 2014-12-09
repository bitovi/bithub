require 'spec_helper'
require 'services/crawler/supervisors/support/supervision_node'

describe SupervisionNode do
  let(:sup_tree) do
    SupervisionNode.new(
      SupervisionNode.new(
        SupervisionNode.new(
          SupervisionNode.new(
            nil, Node.new('main')
          ), BrandInfo.new(1501, 'bitovi')
        ), EmbedInfo.new(2452, 'code')
      ), ServiceInfo.new(3396, 'github', 'repo')
    )
  end

  describe '.from_message' do
    it 'recursively traverses the message scope, creating Tree nodes' do
      msg_arr = %w(main 1501/bitovi 2452/code 3396/github_repo)
      tree = SupervisionNode.from_message(msg_arr)
      expect(tree.path).to eq %w(main 1501/bitovi 2452/code 3396/github_repo)
      expect(tree.brand.to_s).to eq '1501/bitovi'
      expect(tree.embed.to_s).to eq '2452/code'
      expect(tree.service.to_s).to eq '3396/github_repo'
      expect(tree.actor_name).to eq 'main->1501/bitovi->2452/code->3396/github_repo'.to_sym
    end
  end

  describe '#path' do
    it 'recursively calculates the current path' do
      expect(sup_tree.path).to eq %w(main 1501/bitovi 2452/code 3396/github_repo)
    end
  end
  
  describe '#path' do
    it 'recursively calculates the current path, omitting the root node' do
      expect(sup_tree.rootles_path).to eq %w(1501/bitovi 2452/code 3396/github_repo)
    end
  end

  describe '#actor_name' do
    it 'converts the current path to an array of strings that identify an actor' do
      expect(sup_tree.actor_name).to eq :'main->1501/bitovi->2452/code->3396/github_repo'
    end
  end

  describe '#brand_info' do
    it 'finds the brand information in the tree' do
      expect(sup_tree.brand).to eq BrandInfo.new(1501, 'bitovi')
    end
  end

  describe '#embed_info' do
    it 'finds the embed information in the tree' do
      expect(sup_tree.embed).to eq EmbedInfo.new(2452, 'code')
    end
  end

  describe '#service_info' do
    it 'finds the service information in the tree' do
      expect(sup_tree.service).to eq ServiceInfo.new(3396, 'github', 'repo')
    end
  end
end
