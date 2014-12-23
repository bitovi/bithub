steal('funcunit', 'models/appstate.js', './hub-list.js', function(F, AppState){
	QUnit.module('Hub List', {
		beforeEach : function(){
			var template = can.stache('<bh-hub-list state="{state}"></bh-hub-list>');
			$('#qunit-fixture').html(template({
				state : new AppState({
					page : 'hub-list'
				})
			}));
		},
		afterEach : function(){

		}
	});

	QUnit.test('Hub List is shown', 1, function(assert){
		QUnit.stop();
		F('bh-hub-list').exists(function(){
			assert.ok(true);
			QUnit.start();
		});
	});

	QUnit.test('Expand button works', 1, function(assert){
		QUnit.stop();
		F('bh-hub-list [can-click=toggleExpandedRow]').exists().click();
		F('bh-hub-list .expanded-services').exists(function(){
			assert.ok(true);
			QUnit.start();
		});
	});
});