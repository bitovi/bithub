import "./hub-list";
import can from "can/";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

var template = can.stache("<bh-hub-list state='{state}'></bh-hub-list>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

QUnit.module('Hub List');

QUnit.test('Hub List', 1, function(assert){
	renderTemplate({
		state: new can.Map()
	});
	F('bh-hub-list').exists();
	F('bh-hub-list [can-click=toggleExpandedRow]').exists().click();
	F('bh-hub-list .expanded-services').exists('Expand button exists');
});
