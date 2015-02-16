require 'spec_helper'
require 'supervisors/main'
require 'command_handler'
require 'configuration_fetcher'

Message = Struct.new(:title, :body)

describe "Propagation of commands" do

  before do
    Celluloid.boot
    Celluloid::Actor[:configurator] = ConfigurationFetcher.new
  end

  after do
    Celluloid.shutdown
  end

  describe '#stop_brand_supervisor' do
    it 'stops the designated brand supervisor' do
      target = SupervisionNode.from_message ['main', {id: 42, name: 'brand_name'}]
      main_sup = Supervisors::Main.new

      expect do
        main_sup.handle_cmd(target, :stop)
      end.to change { main_sup.children.size }.from(1).to(0)
    end
  end

  describe '#stop_embed_supervisor' do
    it 'stops the designated embed supervisor' do
      prev = SupervisionNode.from_message ['main']
      target = SupervisionNode.from_message ['main', {id: 42, name: 'brand_name'}, {id: 17, name: 'my_embed'}]
      brand_sup = Supervisors::Brand.new prev, BrandInfo.new(42, 'foo')

      expect do
        brand_sup.handle_cmd(target, :stop)
      end.to change { brand_sup.children.size }.from(2).to(1)
    end
  end

  describe '#stop_service_supervisor' do
    it 'stops the designated service supervisor' do
      prev = SupervisionNode.from_message ['main', {id: 42, name: 'foo'}]
      target = SupervisionNode.from_message ['main', {id: 42, name: 'foo'}, {id: 24, name: 'bar'}, {id: 6, feed_name: 'rss', type_name: 'post'}]
      embed_sup = Supervisors::Embed.new prev, EmbedInfo.new(24, 'bar')

      expect do
        embed_sup.handle_cmd(target, :stop)
      end.to change { embed_sup.children.size }.from(3).to(2)
    end
  end
end
