require 'spec_helper'

describe ScopeApplier do
  before(:all) do
    logic_analyzer = QueryLogicAnalyzer.new(Event)
    @scope_applier = ScopeApplier.new(logic_analyzer)
  end

  describe '.apply_muster_query_to_scope' do
    it 'should apply muster params to the scope' do
      scope_to_test = Event.scoped; params = { includes: 'activities', joins: 'rules' }
      scope_to_test = @scope_applier.apply_muster_query_to_scope(scope_to_test, params)
      expect(scope_to_test.joins_values).to eq(['rules'])
      expect(scope_to_test.includes_values).to eq(['activities'])
    end
  end

  describe '.apply_tag_based_params_to_scope' do
    it 'should apply tag based filtering params to the scope'
    # Don't know how to test scopes after tagged_with
  end

  describe ".apply_negated_attrs_to_scope" do
    it "should apply negated attrs to the scope" do
      scope_to_test = Event.scoped; params = { title: 'Some title', url: '!http://some.link.com'}
      scope_to_test = @scope_applier.apply_negated_attrs_to_scope(scope_to_test, params)
      expect(scope_to_test.where_values).to eq(["events.url <> 'http://some.link.com'"])
    end
  end

  describe '.apply_regular_params_to_scope' do
    it 'should apply regular filtering params to the scope' do
      scope_to_test = Event.scoped; params = { id: '1', title: 'Whats up?'}
      scope_to_test = @scope_applier.apply_regular_params_to_scope(scope_to_test, params)
      expect(scope_to_test.where_values_hash).to eq({'id' => '1', 'title' => 'Whats up?'})
    end
  end
  
  describe '.apply_order_to_scope' do
    context 'when handling virtual attrs' do
      it 'should replace virtual attrs with calculated ones and apply a modified statement to the scope' do
        scope_to_test = Event.scoped; muster_query = Hash[:order, ['score asc', 'upvotes desc']]
        scope_to_test = @scope_applier.apply_order_to_scope(scope_to_test, muster_query)
        scope_to_test.order_values.should =~ ['total_score asc', 'total_upvotes desc']
      end
    end
    
    context 'when handling proper attrs' do
      it 'should apply unmodified order statement to the scope' do
        scope_to_test = Event.scoped; muster_query = Hash[:order, ['id asc']]
        scope_to_test = @scope_applier.apply_order_to_scope(scope_to_test, muster_query)
        scope_to_test.order_values.should =~ ['id asc']
      end
    end
  end
end
