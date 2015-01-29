steal(
'can/component',
'./bit.stache!',
'./bit.less!',
'components/image-gallery',
'components/body-wrap',
function(Component, initView){
	return Component.extend({
		tag: 'bh-bit',
		template : initView,
		events : {

		},
		helpers : {
			formattedTitle : function(title){
				title = can.isFunction(title) ? title() : title;
				if(title && title !== 'undefined'){
					return title;
				}
				return "";
			}
		}
	})
})