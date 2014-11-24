steal(
'can/component',
'./payments.stache!',
'models',
'style',
'./payments.less!',
'can/map/define',
function(Component, initView, Models){

	Component.extend({
		tag : 'bh-payments',
		template : initView,
		scope : {
			define : {
				
			}
		}
	});

})