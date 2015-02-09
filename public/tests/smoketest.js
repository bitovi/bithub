(function(){
	F.timeout = 60 * 1000;

	var hubListExists = function(){
		F('bh-hub-list table.table', 0).exists('List of hubs is shown');
		F('bh-hub-list .edit-hub-btn', 0).exists('Edit hub button exists');
	}

	QUnit.module('Smoketest', {

		beforeEach : function(){

		},
		afterEach : function(){

		}
	});

	QUnit.test('Registration', function(){
		F('#account_email', 0).exists('Email input exists');
		F('#account_email', 0).type('foo@bar.com');
		F('#account_password', 0).type('5up3r1337');
		F('#account_password_confirmation', 0).type('5up3r1337');
		F('input[name="commit"]', 0).click();
		F('[can-click=createAndEditHub]', 0).exists('User is registered');
		F('[can-click=createAndEditHub]', 0).click();
		F('bh-sidebar', 0).exists('Hub is created');
		F('.hub-name-wrap', 0).click();
		F('input.hub-name', 0).exists('Editing hub name');
		F.wait(1000, function(){
			F('input.hub-name', 0).type("Some awesome name\r");
			F('.hub-name-wrap', 0).text(/Some awesome name/);
			F('[data-feed=rss]', 0).click();
			F('[can-value="map.config.url"]', 0).type('http://retroaktive.me/rss');
			F('[can-value="map.config.tag_with"]', 0).type('retro');
			F('button.save-service', 0).click();
			F('bh-service-loader', 0).exists('Data is loading');
			F('bh-bit', 0).exists('Data is loaded')
			F('.back-to-admin', 0).click();
			
		});
		
	})

	QUnit.test('List of hubs is shown', function(assert){
		hubListExists();
	})

	QUnit.test('Expanding a hub will show the expanded list', function(assert){
		hubListExists();
		F('bh-hub-list [can-click=toggleExpandedRow]', 0).click();
		F('bh-hub-list .expanded-services', 0).exists('List of services for hub is shown');
	});

	QUnit.test('Clicking on the embed link will take you to the sidebar layout', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn', 0).click();
		F('bh-sidebar', 0).exists('Sidebar layout is open');
		F('.back-to-admin', 0).click();
	});

	QUnit.test('Opening hub will load the bits', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn',0 ).click();
		F('bh-bits',0).exists('Bits are loaded');
		F('bh-bits bh-bit',0 ).exists('Bits exist');
		F('.back-to-admin', 0).click();
	});

	QUnit.test('Editing service works', function(assert){
		hubListExists();
		F('bh-hub-list .edit-hub-btn', 0).click();
		F('bh-services-list', 0).exists('List of services exists');
		F('[can-click=editService]', 0).exists('Edit service button exists');
		F('[can-click=editService]', 0).click();
		F('bh-rss-site-service', 0).exists('Edit service form exists');
		F('.back-to-admin', 0).click();
	})

	QUnit.test('Deleting hub works', function(assert){
		hubListExists();
		F('bh-hub-list [can-click=destroyHub]', 0).click();
		F('bh-hub-list table.table', 0).exists('List of hubs does not exist');
	})
})();