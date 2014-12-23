steal(
'can/util/fixture',
'components/hub-list/hub-list-tests.js',
'components/sidebar/sidebar-tests.js',
'components/tag-list/tag-list-tests.js',
'./smoketest.js',
function(){
	can.route.ready(true);
	can.fixture.on = true;
	QUnit.config.reorder = false;
	QUnit.start();
});