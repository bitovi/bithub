steal('funcunit', 'kickstart.js', function(F, kickstart){

	var hubListExists = function(){
		F('bh-hub-list table.table').exists('List of hubs is shown');
		F('bh-hub-list .edit-hub-btn').exists('Edit hub button exists');
	}

	QUnit.module('Smoketest', {

		beforeEach : function(){
			window.location.hash = "";
			kickstart('#qunit-fixture');
		},
		afterEach : function(){

		}
	});



	QUnit.test('List of hubs is shown', function(assert){
		hubListExists();
	})

	QUnit.test('Expanding a hub will show the expanded list', function(assert){
		hubListExists();
		F('bh-hub-list [can-click=toggleExpandedRow]').click();
		F('bh-hub-list .expanded-services').exists('List of services for hub is shown');
	});

	QUnit.test('Clicking on the embed link will take you to the sidebar layout', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn').click();
		F('bh-sidebar').exists('Sidebar layout is open');
	});

	QUnit.test('Opening hub will load the bits', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn').click();
		F('bh-bits').exists('Bits are loaded');
		F('bh-bits bh-bit').exists('Bits exist');
	});

	QUnit.test('Clicking on a service will open the correct form', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn').click();
		F('bh-services-list').exists('List of services exists');
		F('[can-click=toggleNewService][data-feed=disqus]').exists('Add Service buttons exist');
		F('[can-click=toggleNewService][data-feed=disqus]').click();
		F('bh-disqus-forum-service').exists('Add Disqus form is shown');
		F('[can-click=toggleNewService][data-feed=disqus]').click();
		F('bh-disqus-forum-service').missing('Add Disqus form is removed');
	});

	QUnit.test('Editing service works', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn').click();
		F('bh-services-list').exists('List of services exists');
		F('[can-click=editService]').exists('Edit service button exists');
		F('[can-click=editService]').click();
		F('bh-rss-site-service').exists('Edit service form exists');
	})
});