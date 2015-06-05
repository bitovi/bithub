import "./moderation-rules";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import Models from "models/";

var template = can.stache("<bh-moderation-rules filters='{filters}' hub='{hub}'></bh-moderation-rules>");

var filterData = {
	"natlang_queries": [
		{
			"is_negated": false,
			"val": "foober",
			"op": "contains_all",
			"attr_name": "content",
			"id": 10001
		}
	],
	"embed_id": 10001,
	"action": "block",
	"id": 10001
};

var Hub = can.Map.extend({});

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var renderTemplateAndCheckForFilters = function(){
	var filters = new Models.Filter.List([
		new Models.Filter(filterData)
	]);
	var hub = new Hub({id : 10001});

	renderTemplate({
		filters: filters,
		hub: hub
	});

	F('bh-moderation-rules').exists('Moderation rules are rendered');
	F('bh-moderation-rules .filter-wrap').size(1, 'Filter is rendered');
};


QUnit.module('Moderation rules test');

QUnit.test('Filters are rendered', function(){
	renderTemplateAndCheckForFilters();
});

QUnit.test('Filters can be added', function(){
	renderTemplateAndCheckForFilters();
	F('bh-moderation-rules [can-click=addFilter]').click();
	F('bh-moderation-rules .filter-wrap').size(2, 'Filter is added');
});

QUnit.test('Filters can be removed', function(){
	var filters = new Models.Filter.List([
		new Models.Filter(filterData)
	]);
	var hub = new Hub({id : 10001});

	renderTemplate({
		filters: filters,
		hub: hub
	});

	F('bh-moderation-rules [can-click=markToDestroy]').click();
	F('bh-moderation-rules .filter-wrap').size(0, 'Filter is removed');
	F.wait(1, function(){
		ok(filters[0].__shouldDelete, 'Filter is marked for deletion');
	});
});

QUnit.test('Input fields', function(){
	var filters = new Models.Filter.List([
		new Models.Filter(filterData)
	]);
	var hub = new Hub({id : 1});

	renderTemplate({
		filters: filters,
		hub: hub
	});

	F('bh-moderation-rules textarea[can-value=val]').exists('Textarea is rendered');

	F.wait(1, function(){
		filters.attr('0.natlang_queries.0.op', 'is');
		F('bh-moderation-rules input[can-value=val]').exists('Input field is rendered');
		
	});

	F.wait(1, function(){
		filters.attr('0.natlang_queries.0.op', 'contains_phrase');
		F('bh-moderation-rules input[can-value=val]').exists('Input field is rendered');
	});

	F.wait(1, function(){
		filters.attr('0.natlang_queries.0.attr_name', 'feed_name');
		F('bh-moderation-rules select[can-value=val]').exists('Select field is rendered');
	});
	
});

QUnit.test('Available Verbs', function(){
	var filters = new Models.Filter.List([
		new Models.Filter(filterData)
	]);
	var hub = new Hub({id : 10001});

	renderTemplate({
		filters: filters,
		hub: hub
	});
	
	F('bh-moderation-rules select[can-value=operation] option').size(9, 'All verbs are available');

	F.wait(1, function(){
		filters.attr('0.natlang_queries.0.attr_name', 'feed_name');
		F('bh-moderation-rules select[can-value=operation] option').size(2, 'For feeds, only 2 verbs are available');
	});
});
