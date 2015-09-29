import "./moderation";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";
import fixture from "can/util/fixture/";

var template = can.stache("<bh-moderation state='{state}'></bh-moderation>");

var Hub = can.Map.extend({
	save : function(){
		QUnit.ok(true, 'Save Called');
	}
});

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};


var State = can.Map.extend({
	resetEmbed : function(){
		ok(true, "Reset Embed Called");
	}
});

var Hub = can.Map.extend({
	moderate : function(){
		ok(true, "Moderate called");
		return can.Deferred().resolve({id: this.attr('id')}).promise();
	},
	save : function(){
		ok(true, "Save called");
		return can.Deferred().resolve({id: this.attr('id')}).promise();
	}
});

QUnit.module("Moderation Tests", {
	beforeEach : function(){
		var fixtureData = [
			{
				"natlang_queries": [
					{
						"is_negated": false,
						"val": "foober",
						"op": "contains_all",
						"attr_name": "content",
						"id": 1
					}
				],
				"embed_id": "blocking-and-approving",
				"action": "block",
				"id": 1
			},
			{
				"natlang_queries": [
					{
						"is_negated": false,
						"val": "testing",
						"op": "contains_all",
						"attr_name": "content",
						"id": 2
					}
				],
				"embed_id": "blocking-and-approving",
				"action": "approve",
				"id": 2
			},
			{
				"natlang_queries": [
					{
						"is_negated": false,
						"val": "testing",
						"op": "contains_all",
						"attr_name": "content",
						"id": 3
					}
				],
				"embed_id": "approving",
				"action": "approve",
				"id": 3
			},
			{
				"natlang_queries": [
					{
						"is_negated": false,
						"val": "foober",
						"op": "contains_all",
						"attr_name": "content",
						"id": 4
					}
				],
				"embed_id": "blocking",
				"action": "block",
				"id": 4
			}
		];

		var STORE = fixture.store(fixtureData);
		fixture({
			"/api/v3/filters": STORE.findAll,
			"PUT /api/v3/filters/{id}" : STORE.update,
			"DELETE /api/v3/filters/{id}" : STORE.destroy
		});
		fixture.on = true;
	},
	afterEach : function(){
		fixture({
			"/api/v3/filters" : null,
			"PUT /api/v3/filters/{id}" : null,
			"DELETE /api/v3/filters/{id}" : null
		});
		fixture.on = false;
	}
});

QUnit.test("Moderation with blocking and approving", 7, function(){
	renderTemplate({
		state: new State({
			hub: new Hub({
				id: 'blocking-and-approving',
				approved_by_default: false
			})
		})
	});

	F('bh-moderation').exists('Moderation is rendered');
	F('input[can-change=toggleApprovedByDefault][value=0]:checked')
		.exists('Hub items are not approved by default');
	F('bh-moderation bh-moderation-rules.approving').exists('Approving filters are rendered');
	F('bh-moderation bh-moderation-rules.blocking').exists('Blocking filters are rendered');
	F('bh-moderation button.btn-save-moderation').click();
});

QUnit.test("Moderation with only blocking filters present", function(){
	renderTemplate({
		state: new State({
			hub: new Hub({
				id: 'blocking',
				approved_by_default: false
			})
		})
	});
	F('bh-moderation').exists('Moderation is rendered');
	F('bh-moderation bh-moderation-rules.approving').missing('Approving filters are missing');
	F('bh-moderation bh-moderation-rules.blocking').exists('Blocking filters exist');
});

QUnit.test("Moderation with only approving filters present", function(){
	renderTemplate({
		state: new State({
			hub: new Hub({
				id: 'approving',
				approved_by_default: false
			})
		})
	});
	F('bh-moderation').exists('Moderation is rendered');
	F('bh-moderation bh-moderation-rules.blocking').missing('Blocking filters are missing');
	F('bh-moderation bh-moderation-rules.approving').exists('Approving filters exist');
});

QUnit.test("Both moderation and approving filters exist, but only blocking should be shown because hub is approving by default", function(){
	renderTemplate({
		state: new State({
			hub: new Hub({
				id: 'blocking-and-approving',
				approved_by_default: true
			})
		})
	});
	F('bh-moderation').exists('Moderation is rendered');
	F('bh-moderation bh-moderation-rules.approving').missing('Approving filters are missing');
	F('bh-moderation bh-moderation-rules.blocking').exists('Blocking filters exist');
});

QUnit.test("Add filter", function(){
	renderTemplate({
		state: new State({
			hub: new Hub({
				id: 'blocking-and-approving',
				approved_by_default: false
			})
		})
	});

	F('bh-moderation').exists('Moderation is rendered');
	F('bh-moderation .filter-wrap').size(2, 'Two moderation filters are rendered');
	F('bh-moderation [can-click=addFilter]:first').click();
	F('bh-moderation .filter-wrap').size(3, 'Three moderation filters are rendered');
});

QUnit.test("Remove filter", function(){
	renderTemplate({
		state: new State({
			hub: new Hub({
				id: 'blocking-and-approving',
				approved_by_default: false
			})
		})
	});
	F('bh-moderation').exists('Moderation is rendered');
	F('bh-moderation .filter-wrap').size(2, 'Two moderation filters are rendered');
	F('bh-moderation .filter-wrap:first [can-click=markToDestroy]').click();
	F('bh-moderation .filter-wrap').size(1, 'One filter is marked for destroying');
});
