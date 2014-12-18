steal(
'can/component',
'./service-loader.stache!',
'./service-loader.less!',
function(Component, initView){
	return Component.extend({
		tag : 'bh-service-loader',
		template : initView,
		scope : {
			
		}
	});
});