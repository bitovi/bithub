import "./suggestions";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

import fixture from "can/util/fixture/";

var template = can.stache("<bh-suggestions val='{val}' allow-extra='{allowExtra}' brand-identity-id='{brandIdentityId}' service='{service}'></bh-analytics>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};


var fixtureUrl = '/api/v3/services/suggestions/repo?brand_identity_id={brandIdentityId}';

QUnit.module('Suggestions Tests', {
	beforeEach : function(){
		fixture(fixtureUrl, function(req){
			if(req.data.brandIdentityId !== '1'){
				return [];
			}
			return [
				{
					"name": "aljosa/muchi.me",
					"id": "aljosa/muchi.me"
				},
				{
					"name": "retro/apitizer",
					"id": "retro/apitizer"
				}
			];
		});
		fixture.delay = 100;
		fixture.on = true;
	},
	afterEach : function(){
		fixture.on = false;
		fixture.delay = 0;
		fixture(fixtureUrl, null);
	}
});

QUnit.test("Suggestions are listed", function(){
	renderTemplate({
		brandIdentityId: 1,
		service: 'repo'
	});
	
	F('bh-suggestions .loader').exists('Loader is displayed');
	F('bh-suggestions .panel').exists('Suggestions are loaded');
	F('bh-suggestions td').text(/aljosa\/muchi\.me/, 'First suggestion is rendered');
	F('bh-suggestions td').text(/retro\/apitizer/, 'Secong suggestion is rendered');

});

QUnit.test("When there are no suggestions, info is shown", function(){
	renderTemplate({
		brandIdentityId: 2,
		service: 'repo'
	});

	F('bh-suggestions .panel').missing('Suggestions are not loaded');
	F('bh-suggestions .alert-info').exists('Info panel is shown instead of suggestions');
});

QUnit.test("Allow extra", function(){
	renderTemplate({
		brandIdentityId: 1,
		service: 'repo',
		allowExtra: true
	});
	
	F('bh-suggestions [can-value=val]').exists('Input field for extra is shown');
	F('bh-suggestions [can-value=val]').type('foo/bar[\t]');
	F.wait(1, function(){
		QUnit.equal(F('bh-suggestions').scope().attr('val'), 'foo/bar', 'Val is set to extra value');
	});
});

QUnit.test("Selecting suggestion", function(){
	renderTemplate({
		brandIdentityId: 1,
		service: 'repo'
	});
	
	F('bh-suggestions .panel').exists('Suggestions are loaded');
	F('tr:first').click();
	F('tr.info td').text(/aljosa\/muchi\.me/, 'Suggestion is selected');
	F.wait(1, function(){
		QUnit.equal(F('bh-suggestions').scope().attr('val'), 'aljosa/muchi.me', 'Suggestion is set on scope');
	});
});

QUnit.test("Selecting suggestion is possible through the attribute", function(){
	renderTemplate({
		brandIdentityId: 1,
		service: 'repo',
		val: 'aljosa/muchi.me'
	});
	F('tr.info td').text(/aljosa\/muchi\.me/, 'Suggestion is selected');
});

QUnit.test("Clicking on a selected suggestion will hide it", function(){
	renderTemplate({
		brandIdentityId: 1,
		service: 'repo',
		val: 'aljosa/muchi.me'
	});

	F('tr.info').click();
	F('tr.info').missing('Suggestion is deselected');
});

QUnit.test("Selecting a suggestion from the list will hide the extra input", function(){
	renderTemplate({
		brandIdentityId: 1,
		service: 'repo',
		allowExtra: true
	});

	F('[can-value=val]').exists('Extra input is shown');
	F('tr:first').click();
	F('tr.info').exists('Suggestion is selected');
	F('[can-value=val]').missing('Extra input is hidden');
	F('tr.info').click();
	F('tr.info').missing('Suggestion is deselected');
	F('[can-value=val]').exists('Extra input is shown');
});
