require 'spec_helper'
require 'supervisors/embed'
require 'supervisors/node_types/node_types'
require_relative 'support/service_supervisor_mock'

describe Supervisors::Embed do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  let(:config) do
    JSON.parse(File.read('spec/support/responses/configurator/test_account_config.json'), symbolize_names: true)
  end

  let(:embed_sup_parent_node) do
    SupervisionNode.from_message({
      main: { watever: 'main' },
      brand: { id: 42, name: 'my_brand' }
    })
  end

  let(:target) do
    SupervisionNode.from_message({
      main: { doesntexist: 'yes' },
      brand: { id: 42, name: 'my_brand' },
      embed: { id: 24, name: 'my_embed' },
      service: { id: 6, feed_name: 'rss', type_name: 'site', config: {}}
    })
  end

  describe '#handle_cmd' do
    it 'starts the designated service supervisor' do
      embed_sup = Supervisors::Embed.new(embed_sup_parent_node, NodeTypes::EmbedInfo.new(24, 'bar'))
      
      expect do
        embed_sup.handle_cmd(target, :start)
      end.to change { embed_sup.children.size }.from(0).to(1)
    end

    it 'stops the designated service supervisor' do
      embed_sup = Supervisors::Embed.new(embed_sup_parent_node, NodeTypes::EmbedInfo.new(24, 'bar'))
      embed_sup.boot(config.fetch(:brands).first.fetch(:embeds).last)

      expect do
        embed_sup.handle_cmd(target, :stop)
      end.to change { embed_sup.children.size }.from(3).to(2)
    end
  end
end
