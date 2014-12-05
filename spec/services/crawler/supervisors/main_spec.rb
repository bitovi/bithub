require 'spec_helper'
require 'supervisors/main'
require 'commander'
require 'configurator'

Message = Struct.new(:title, :body)

describe "Propagation of commands" do

  before do 
    Celluloid.boot
    Celluloid::Actor[:configurator] = Configurator.new({environment: 'test'})
  end

  after do
    Celluloid.shutdown
  end

  describe '#stop_brand_supervisor' do
    it 'stops the designated brand supervisor' do
      target = TreePath.from_message(%w(main neektza))
      main_sup = Supervisors::Main.new

      expect do
        main_sup.handle_cmd(target, :stop)
      end.to change { main_sup.children.size }.from(1).to(0)
    end
  end
  
  describe '#stop_embed_supervisor' do
    it 'stops the designated embed supervisor' do
      prev = TreePath.from_message(%w(main))
      target = TreePath.from_message(%w(main neektza code))
      brand_sup = Supervisors::Brand.new(prev, 'neektza')

      expect do
        brand_sup.handle_cmd(target, :stop)
      end.to change { brand_sup.children.size }.from(1).to(0)
    end
  end
  
  describe '#stop_service_supervisor' do
    it 'stops the designated service supervisor' do
      prev = TreePath.from_message(%w(main neektza))
      target = TreePath.from_message(%w(main neektza code stackexchange+tags))
      embed_sup = Supervisors::Embed.new(prev, 'code')

      expect do
        embed_sup.handle_cmd(target, :stop)
      end.to change { embed_sup.children.size }.from(2).to(1)
    end
  end
end
