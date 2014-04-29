require 'spec_helper'
require 'bunny'
require 'lib/amqp_helpers'

describe AmqpHelpers do

  class DummyClass
  end

  before(:each) do
    @publisher = DummyClass.new
    @publisher.extend(AmqpHelpers)
  end

  describe "#rabbit" do
    it "opens a new connection to rabbitmq" do
      x_args = {
        :exchange_name => 'x.crawler',
        :exchange_type => 'direct',
      }

      @publisher.rabbit(x_args)

      expect(@publisher.exchange).to be_instance_of Bunny::Exchange
      expect(@publisher.exchange.name).to eq 'x.crawler'
      expect(@publisher.exchange.durable?).to be_false
      expect(@publisher.exchange.auto_delete?).to be_true
    end
  end
end
