import "./analytics";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

var template = can.stache("<bh-analytics  state='{state}'></bh-analytics>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var State = can.Map.extend();

QUnit.module('Analytics Tests');

QUnit.test('Clicking on a tab will render a different component', function(){
	renderTemplate({
		state : new State({
			hub : {
				name : 'Hub Name'
			}
		})
	});
	
	F('bh-analytics h2').text('Hub Name Analytics', 'Title is rendered');
	F('li.active a[data-tab=interaction]').exists('Interaction analytics tab is active by default');
	F('bh-interaction-analytics').exists('Interaction analytics component is rendered');
	F('[data-tab=crawler]').click();
	F('li.active a[data-tab=crawler]').exists('Crawler analytics tab is activated');
	F('bh-crawler-analytics').exists('Crawler analytics component is rendered');
});
