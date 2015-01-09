steal(
'can/component',
'./bit.stache!',
'./bit.less!',
function(Component, initView){
	return Component.extend({
		tag: 'bh-bit',
		template : initView,
		events : {

		}
	})
})