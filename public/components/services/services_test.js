import "./services";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import fixture from "can/util/fixture/";
import Models from  "models/";

import "can/map/define/";

var template = can.stache("<bh-services state='{state}'></bh-services>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

can.stache.registerHelper(
	'ifCanAddService',
	function(services, feed, type, opts){
		return opts.fn();
	}
);

var StateMap = can.Map.extend({
	define : {
		services : {
			get : function() {
				var res = new Models.Service.List({
					embed_id: this.attr('hubId')
				});
				console.log(res);
				return res;
			}
		}
	}
});

QUnit.module('Services Test', {
	beforeEach : function(){
		var fixtureData = [
			{
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
			}
		];
		fixture('GET /api/v3/services', function(){
			return fixtureData;
		});
		fixture.delay = 1000;
		fixture.on = true;
	},
	afterEach : function(){
		fixture('GET /api/v3/services', null);
		fixture.on = false;
		fixture.delay = 100;
	}
});

QUnit.test('Services are correctly rendered', function(){
	renderTemplate({
		state : new StateMap({
			hubId: 1,
			loadingServices: []
		})
	});
	
	F('bh-services').exists('Services are rendered');
	F('bh-services .pending-wrap').exists('Loader is rendered');
	F('bh-services bh-services-list').exists('Services list is rendered');
	F('bh-services .service-slider-wrap li').exists('Feed buttons are loaded');
});

QUnit.test('Clicking on a feed button will toggle the service form', function(){
	renderTemplate({
		state : new can.Map({
			hubId: 1,
			loadingServices: []
		})
	});

	F('bh-services li[can-click=toggleNewService]:first').click();
	F('bh-services bh-service-form').exists('Service form is rendered');
	F.wait(1, function(){
		ok(F('bh-services li[can-click=toggleNewService]:first').is('.active'), 'First service button is activated');
	});
	F('bh-services li[can-click=toggleNewService].active').click();
	F('bh-services li[can-click=toggleNewService].active').missing('First service button is deactivated');
});
