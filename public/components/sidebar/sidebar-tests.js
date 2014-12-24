steal('funcunit', 'models/appstate.js', './sidebar.js', function(F, AppState){
	QUnit.module('Sidebar', {
		beforeEach : function(){
			var template = can.stache('<bh-sidebar state="{state}"></bh-sidebar>');
			$('#qunit-fixture').html(template({
				state : new AppState({
					page : 'sidebar',
					hubId : 1
				})
			}));
		},
		afterEach : function(){

		}
	});

	QUnit.test('Sidebar is shown', 1, function(assert){
		QUnit.stop();
		F('bh-sidebar').exists(function(){
			assert.ok(true);
			QUnit.start();
		});
	});

	QUnit.test('Editing sidebar name works', function(assert){
		QUnit.stop();
		F('bh-sidebar').exists();
		F('bh-sidebar [can-dblclick=toggleHubEditing]').dblclick();
		F('input.hub-name').exists();
		F('input.hub-name').type('\b\b\b\b\b\b\bBAR\r');
		F('bh-sidebar h2').text('BAR', function(){
			assert.ok(true);
			QUnit.start();
		})
	});

});