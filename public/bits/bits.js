steal(
'can/component',
'./bits.stache!',
'models',
'./bits.less!',
'can/map/define',
'components/service-loader',
function(Component, initView, Models){
	return Component.extend({
		tag : 'bh-bits',
		template : initView,
		scope : {
			init : function(){
				var self = this;
				Models.Bit.findAll({hubId: can.route.attr('hubId')}).then(function(data){
					var bits = self.attr('bits');
					bits.unshift.apply(bits, data);
				});
			}
		}
	})
});