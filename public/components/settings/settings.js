steal(
'can/component',
'./settings.stache!',
'models',
'style',
'./settings.less!',
'can/map/define',
function(Component, initView, Models){

	Component.extend({
		tag : 'bh-settings',
		template : initView,
		scope : {
			define : {
				
			}
		}
	});

})