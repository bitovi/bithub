import "./hub-list";
import can from "can/";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import fixture from "can/util/fixture/";

var template = can.stache("<bh-hub-list state='{state}'></bh-hub-list>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

QUnit.module('Hub List', {
	beforeEach : function(){
		fixture('/api/v3/embeds', "./fixtures/embeds.json");
		fixture('/api/v3/services', "./fixtures/services.json");
		fixture.on = true;
		fixture.delay = 100;
	},
	afterEach : function(){
		fixture('/api/v3/embeds', null);
		fixture('/api/v3/services', null);
		fixture.on = false;
		
	}
});

QUnit.test('Hub List', 1, function(assert){
	renderTemplate({
		state: new can.Map()
	});
	F('bh-hub-list').exists();
	F('bh-hub-list [can-click=toggleExpandedRow]').exists().click();
	F('bh-hub-list .expanded-services').exists('Expand button exists');
});
