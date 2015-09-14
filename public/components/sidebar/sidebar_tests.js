import "./sidebar";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import Models from "models/";
import fixture from "can/util/fixture/";

var template = can.stache("<bh-sidebar state='{state}'></bh-sidebar>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var State = can.Map.extend({
	sidebarIsExpanded: true
});

QUnit.module('Sidebar tests', {
	beforeEach : function(){
		fixture.on = true;
		fixture.delay = 100;
		fixture('/api/v3/filters', function(){
			return [];
		});
	},
	afterEach : function(){
		fixture.on = false;
		fixture('/api/v3/filters', null);
	}
});

QUnit.test("Sidebar tabs", function(){
	var state = new State({
		panel: 'services',
		loadingServices: [],
		currentBrand: new Models.Brand(),
		hub : new Models.Hub()
	});

	renderTemplate({
		state: state
	});

	F('bh-sidebar').exists('Sidebar is loaded');
	F('bh-sidebar .service-tabs a').size(3, 'Links are rendered');
	F('bh-sidebar .service-tabs a.active').exists('Active link is set');
	F('bh-sidebar .service-tabs a.active').text(/Services/, 'Services tab is active');
	F('bh-sidebar bh-services').exists('Services panel is loaded');
	F.wait(1, function(){
		state.attr('panel', 'moderation');
		F('bh-sidebar .service-tabs a.active').text(/Moderation/, 'Active tab is switched to moderation');
		F('bh-sidebar bh-moderation').exists('Moderation panel is rendered');
	});
});

QUnit.test('Expanding/collapsing sidebar', function(){
	var state = new State({
		panel: 'services',
		loadingServices: [],
		currentBrand: new Models.Brand(),
		hub : new Models.Hub()
	});

	renderTemplate({
		state: state
	});
	
	F('bh-sidebar .header').exists('Sidebar is rendered');
	F('bh-sidebar [can-click=toggleSidebarPosition]').click();
	F.wait(1, function(){
		ok(!state.attr('sidebarIsExpanded'), 'Sidebar collapsed/expanded state is reflected on the state object');
	});
});
