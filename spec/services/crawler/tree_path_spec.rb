require 'spec_helper'
require 'services/crawler/supervisors/support/service_info'
require 'services/crawler/supervisors/support/tree_path'

describe TreePath do
  let(:si) { ServiceInfo.new('a_service_feed', 'a_service_type') }
  let(:sup_tree) do
    TreePath.new(
      TreePath.new(
        TreePath.new(
          TreePath.new(
            nil, 'main', :root
          ), 'a_brand', :brand_name
        ), 'an_embed', :embed_name
      ), si, :service_info
    )
  end

  describe '#path' do
    it 'recursively calculates the current path' do
      expect(sup_tree.path).to eq %w(main a_brand an_embed a_service_feed a_service_type)
    end
  end
  
  describe '#path' do
    it 'recursively calculates the current path, omitting the root node' do
      expect(sup_tree.rootles_path).to eq %w(a_brand an_embed a_service_feed a_service_type)
    end
  end

  describe '#actor_name' do
    it 'converts the current path to an array of strings that identify an actor' do
      expect(sup_tree.actor_name).to eq :'main->a_brand->an_embed->a_service_feed->a_service_type'
    end
  end

  describe '#brand_name' do
    it 'finds the brand_name in the tree' do
      expect(sup_tree.brand_name).to eq 'a_brand'
    end
  end

  describe '#embed_name' do
    it 'finds the embed_name in the tree' do
      expect(sup_tree.embed_name).to eq 'an_embed'
    end
  end
  
  describe '#service_name' do
    it 'finds the composed service feed and type name in the tree' do
      expect(sup_tree.service_name).to eq 'a_service_feed_a_service_type'
    end
  end

  describe '#service_info' do
    it 'finds the service feed_name in the tree' do
      expect(sup_tree.service_feed).to eq 'a_service_feed'
    end
  end
  
  describe '#service_info' do
    it 'finds the service type_name in the tree' do
      expect(sup_tree.service_type).to eq 'a_service_type'
    end
  end


end
