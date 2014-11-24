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
			define : {
				services : {
					get : function(){
						return new Models.Service.List({})
					}
				}
			}
		}
	});
});