steal(
'can/component',
'models',
'./services-list.stache!',
'./services-list.less!',
'can/map/define',
function(Component, Models, initView){
	return Component.extend({
		tag : 'bh-services-list',
		template : initView,
		scope: {
			destroyService: function( service, el, ev) {
				if( confirm('Are you sure?') ) {
					service.destroy();
				}
			}
		}
	});
});
