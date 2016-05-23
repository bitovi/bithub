require 'spec_helper'
require 'supervisors/main'
require 'supervisors/node_types/node_types'
require_relative 'support/service_supervisor_mock'

describe Supervisors::Main do
  before { Celluloid.boot }
  after { Celluloid.shutdown }

  let(:config) do
    JSON.parse(File.read('spec/support/responses/configurator/test_user_config.json'), symbolize_names: true)
  end

  let(:target) do
    SupervisionNode.from_message({
      main: { who: 'wat' },
      brand: { id: 42, name: 'brand_name' }
    })
  end

  describe '#stop_brand_supervisor' do
    it 'starts the designated brand supervisor' do
      main_sup = Supervisors::Main.new({ boot_on_init: false })

      expect do
        main_sup.handle_cmd(target, :start)
      end.to change { main_sup.children.size }.from(0).to(1)
    end

    it 'stops the designated brand supervisor' do
      main_sup = Supervisors::Main.new({ boot_on_init: false })
      main_sup.boot(config)

      expect do
        main_sup.handle_cmd(target, :stop)
      end.to change { main_sup.children.size }.from(1).to(0)
    end
  end
end
