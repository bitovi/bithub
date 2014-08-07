require 'domain/spec_helper'
require 'app/domain/scope_applier'
require 'app/domain/query_logic/query.rb'

RSpec.describe ScopeApplier, :type => :domain do

  describe '.apply_muster_query_to_scope' do
    it 'should apply muster params to the scope' do
      scope = Entity.all; params = { includes: 'activities', joins: 'rules' }

      @query_logic = QueryLogic::Query.new scope, params
      scope = ScopeApplier
        .new(scope, @query_logic)
        .apply_muster_query_to_scope(params)
        .result

      expect(scope.joins_values).to eq(['rules'])
      expect(scope.includes_values).to eq(['activities'])
    end
  end

  describe '.apply_tag_based_params_to_scope' do
    it 'should apply tag based filtering params to the scope'
    # Don't know how to test scopes after tagged_with
  end

  describe ".apply_negated_attrs_to_scope" do
    it "should apply negated attrs to the scope" do
      scope = Entity.all; params = { title: 'Some title', url: '!http://some.link.com'}
      @query_logic = QueryLogic::Query.new scope, params
      scope = ScopeApplier
        .new(scope, @query_logic)
        .apply_negated_attrs_to_scope
        .result


      expect(scope.where_values).to eq(["entities.url <> 'http://some.link.com'"])
    end
  end

  describe '.apply_regular_params_to_scope' do
    it 'should apply regular filtering params to the scope' do
      scope = Entity.all; params = { id: '1', title: 'Whats up?'}

      @query_logic = QueryLogic::Query.new scope, params
      scope = ScopeApplier
        .new(scope, @query_logic)
        .apply_regular_params_to_scope
        .result

      expect(scope.where_values_hash).to eq({'id' => '1', 'title' => 'Whats up?'})
    end
  end

  describe '.apply_order_to_scope' do
    context 'when handling virtual attrs' do
      it 'should replace virtual attrs with calculated ones and apply a modified statement to the scope' do
        scope = Entity.all; params = {order: ['score asc', 'upvotes desc']}

        @query_logic = QueryLogic::Query.new scope, params
        scope = ScopeApplier
          .new(scope, @query_logic)
          .apply_order_to_scope
          .result

        expect(scope.order_values).to eq ['total_score asc', 'total_upvotes desc']
      end
    end

    context 'when handling proper attrs' do
      it 'should apply unmodified order statement to the scope' do
        scope = Entity.all; params = {order: ['id asc']}

        @query_logic = QueryLogic::Query.new scope, params
        scope = ScopeApplier
          .new(scope, @query_logic)
          .apply_order_to_scope
          .result

        expect(scope.order_values).to eq ['id asc']
      end
    end
  end
end
