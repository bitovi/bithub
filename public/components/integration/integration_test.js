import "./integration";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import fixture from "can/util/fixture/";

var template = can.stache("<bh-integration state='{state}'></bh-integration>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var presetData = {
	"config": {
		"theme": "dark",
		"live": true
	},
	"name": "Dark Preset",
	"id": 1
};

var State = can.Map.extend({});

window.EMBED_ENDPOINT = 'http://bithub.loc';

QUnit.module("Integration test",{
	beforeEach : function(){
		fixture.on = true;
		fixture("GET /api/v3/presets", function(){
			return [presetData];
		});
		fixture("DELETE /api/v3/presets/{id}", function(){
			return {};
		});
		fixture("PUT /api/v3/presets/{id}", function(req){
			return req.data;
		});
		fixture("POST /api/v3/presets", function(req){
			var data = req.data;
			data.id = Date.now();
			return data;
		});
		renderTemplate({
			state : new State({
				currentBrand : {
					tenant_name: 'foo'
				},
				hub : {
					id : 1
				}
			})
		});
	},
	afterEach : function(){
		fixture.on = false;
		fixture("GET /api/v3/presets", null);
		fixture("DELETE /api/v3/presets/{id}", null);
	}
});

QUnit.test("Integration rendering", function(){
	F('bh-integration').exists('Integration is rendered');
	F('bh-integration tbody tr').size(3, 'Default and loaded presets are rendered');
	F('bh-integration tbody tr:nth-child(2) textarea').exists('Default preset is expanded');
});

QUnit.test("Integration - expanding and editing a preset", function(){
	F('bh-integration [can-click=toggleCurrentPreset]:last').click();
	F('bh-integration tr:last textarea').exists('Loaded preset is expanded');
	F('bh-integration [can-click=editPreset]:last').click();
	F('bh-integration bh-preset-form').exists('Preset form is open');
	F('bh-integration bh-preset-form .clear-preset').click();
	F('bh-integration bh-preset-form').missing('Preset form is removed');
});

QUnit.test('Deleting a preset', function(){
	F('bh-integration [can-click=destroyPreset]:last').click();
	F.confirm(true);
	F('bh-integration tbody tr').size(2, 'Preset is destroyed');
});

QUnit.test('Preset can be created', function(){
	F('bh-integration [can-click=addPreset]').click();
	F('bh-integration bh-preset-form').exists('New preset form is rendered');
	F('bh-integration bh-preset-form [can-value="preset.name"]').type('Foo');
	F('bh-integration bh-preset-form .save-service').click();
	F('bh-integration bh-preset-form .fa-circle-o-notch').exists('Preset is saving');
	F('bh-integration bh-preset-form').missing('Form is closed');
	F('bh-integration tbody tr').size(4, 'Preset is added to the list');
});
