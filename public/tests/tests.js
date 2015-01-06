steal(
'can/util/fixture',
'components/hub-list/hub-list-tests.js',
'components/sidebar/sidebar-tests.js',
'components/tag-list/tag-list-tests.js',
'./smoketest.js',
function(){
	window.location.hash = "";
	can.route.ready(true);
	can.fixture.on = true;
	QUnit.config.reorder = false;


	if(window.Testee) {
		window.Testee.init();
	}

	QUnit.start();
});