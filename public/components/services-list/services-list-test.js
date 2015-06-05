import "./services-list";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import Models from "models/";

var template = can.stache("<bh-services-list services='{services}' state='{state}' current-service='{currentService}'></bh-services-list>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var services =  [
	new Models.Service({
		"error": null,
		"config": {
			"display_name": "bitovi",
			"term": "bitovi"
		},
		"entity_count": 98,
		"brand_identity_id": 1,
		"type_name": "term",
		"feed_name": "twitter",
		"id": 4
	})
];

QUnit.module('Services List Test');

QUnit.test('Services List is correctly rendered', function(){
	renderTemplate({
		services : new can.List(services),
		currentService : new can.compute(),
		state : new can.Map({
			hubId: 1,
			loadingServices: []
		})
	});
	
	F('bh-services-list').exists('Services list is rendered');
	F('bh-services-list tbody tr').size(1, 'Services table is rendered');
});

QUnit.test('Services can be edited', function(){
	renderTemplate({
		services : new can.List(services),
		currentService : new can.compute(),
		state : new can.Map({
			hubId: 1,
			loadingServices: []
		})
	});
	
	F('bh-services-list').exists('Services list is rendered');
	F('bh-services-list [can-click=editService]').click();
	F('bh-services-list bh-service-form').exists('Form is rendered');
});

QUnit.test('Services can be destroyed', function(){
	renderTemplate({
		services : new can.List(services),
		currentService : new can.compute(),
		state : new can.Map({
			hubId: 1,
			loadingServices: []
		})
	});
	
	F('bh-services-list').exists('Services list is rendered');
	F('bh-services-list [can-click=destroyService]').exists('Destroy confirmation dialog is rendered');
});

QUnit.test('Services can be in loading state', function(){
	var servicesList = new can.List(services);
	renderTemplate({
		services : servicesList,
		currentService : new can.compute(),
		state : new can.Map({
			hubId: 1,
			loadingServices: [servicesList[0]]
		})
	});

	F('bh-services-list').exists('Services list is rendered');
	F('bh-services-list tr.loader').exists('Service is in loading state');
	F('bh-services-list tr.loading-service').exists('Service is marked as loading');
});

QUnit.test('Services can have no results', function(){
	var servicesList = new can.List(services);

	renderTemplate({
		services : servicesList,
		currentService : new can.compute(),
		state : new can.Map({
			hubId: 1,
			loadingServices: []
		})
	});
	
	servicesList[0].attr('noResults', true);

	F('bh-services-list').exists('Services list is rendered');
	F('bh-services-list .no-data-alert').exists('Service has no data alert is shown');
	F('bh-services-list [can-click=hideNoResults]').click();
	F('bh-services-list .no-data-alert').missing('Service has no data alert can be hidden');
});

QUnit.test('Services can have be in error state', function(){
	var servicesList = new can.List(services);

	renderTemplate({
		services : servicesList,
		currentService : new can.compute(),
		state : new can.Map({
			hubId: 1,
			loadingServices: []
		})
	});
	
	servicesList[0].attr('error', {
		klass: 'foo',
		message: 'bar'
	});

	F('bh-services-list').exists('Services list is rendered');
	F('bh-services-list tr.errored-service').exists('Service is marked as in error state');
	F('bh-services-list .alert-config-error').missing('Errors are not displayed by default');
	F('bh-services-list [can-click=toggleErrorShowing]').click();
	F('bh-services-list .alert-config-error').exists('Errors are displayed');
});
