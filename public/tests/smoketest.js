steal('funcunit', 'kickstart.js', function(F, kickstart){
	QUnit.module('Smoketest', {

		beforeEach : function(){
			window.location.hash = "";
			kickstart('#qunit-fixture');
		},
		afterEach : function(){

		}
	});

	QUnit.test('List of hubs is shown', function(assert){
		F('bh-hub-list table.table').exists('List of hubs is shown');
	})

	QUnit.test('Expanding a hub will show the expanded list', function(assert){
		F('bh-hub-list table.table').exists('List of hubs is shown');
		F('bh-hub-list [can-click=toggleExpandedRow]').click();
		F('bh-hub-list .expanded-services').exists('List of services for hub is shown');
	});

	QUnit.test('Clicking on the embed link will take you to the sidebar layout', function(assert){
		F('bh-hub-list .edit-hub-btn').exists();
		F('bh-hub-list .edit-hub-btn').click();
		F('bh-sidebar').exists('Sidebar layout is open');
	});

	QUnit.test('Opening hub will load the bits', function(assert){
		F('bh-hub-list .edit-hub-btn').exists();
		F('bh-hub-list .edit-hub-btn').click();
		F('bh-bits').exists('Bits are loaded');
		F('bh-bits bh-bit').exists('Bits exist');
	});
});