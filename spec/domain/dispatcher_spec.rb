require 'domain/spec_helper'

describe Dispatcher do
  let(:event_persistor) { double("event_persistor") }
  let(:entity_persistor) { double("entity_persistor") }
  let(:rl) { ResponseLoader.new }
  
  subject(:dispatcher) { Events::Dispatcher.new(event_persistor, entity_persistor) }
end
