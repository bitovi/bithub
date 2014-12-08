steal(
'can/component',
'./bits.stache!',
'models',
'./bits.less!',
'can/map/define',
function(Component, initView, Models){
	return Component.extend({
		tag : 'bh-bits',
		template : initView,
		scope : {
			define : {
				bits : {
					get : function(){
						return new Models.Bit.List({hubId: can.route.attr('hubId')});
					}
				}
			}
		}
	})
});