require 'spec_helper'
require 'services/crawler/supervisors/support/supervision_node'

describe SupervisionNode do
  before do
    @sup_tree = SupervisionNode.new(
      SupervisionNode.new(
        SupervisionNode.new(
          SupervisionNode.new(
            nil, @root = MainNode.new
          ), @bi = BrandInfo.new(1501, 'bitovi')
        ), @ei = EmbedInfo.new(2452, 'code')
      ), @si = ServiceInfo.new(3396, 'github', 'repo')
    )
  end

  describe '.from_message' do
    it 'recursively traverses the message scope, creating Tree nodes' do
      msg_arr = %w(main 1501/bitovi 2452/code 3396/github_repo)
      tree = SupervisionNode.from_message(msg_arr)
      expect(tree.string_path).to eq %w(main 1501/bitovi 2452/code 3396/github_repo)
      expect(tree.brand.to_s).to eq '1501/bitovi'
      expect(tree.embed.to_s).to eq '2452/code'
      expect(tree.service.to_s).to eq '3396/github_repo'
      expect(tree.actor_name).to eq 'main->1501/bitovi->2452/code->3396/github_repo'.to_sym
    end
  end

  describe '#string_path' do
    it 'recursively calculates the current path, returning the string representation of nodes' do
      expect(@sup_tree.string_path).to eq %w(main 1501/bitovi 2452/code 3396/github_repo)
    end
  end
  
  describe 'path' do
    it 'recursively calculates the current path, returning the unprocessed nodes' do
      expect(@sup_tree.path).to eq [@root, @bi, @ei, @si]
    end
  end

  describe 'rootless' do
    it 'recursively calculates the current path, omitting the root node' do
      expect(@sup_tree.rootless).to eq [@bi, @ei, @si]
    end
  end

  describe '#actor_name' do
    it 'converts the current path to an array of strings that identify an actor' do
      expect(@sup_tree.actor_name).to eq :'main->1501/bitovi->2452/code->3396/github_repo'
    end
  end

  describe '#brand_info' do
    it 'finds the brand information in the tree' do
      expect(@sup_tree.brand).to eq BrandInfo.new(1501, 'bitovi')
    end
  end

  describe '#embed_info' do
    it 'finds the embed information in the tree' do
      expect(@sup_tree.embed).to eq EmbedInfo.new(2452, 'code')
    end
  end

  describe '#service_info' do
    it 'finds the service information in the tree' do
      expect(@sup_tree.service).to eq ServiceInfo.new(3396, 'github', 'repo')
    end
  end
end
