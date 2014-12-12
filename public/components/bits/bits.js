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
						return new Models.Bit.List();
					}
				}
			},
			init : function(){
				var self = this;
				Models.Bit.findAll({hubId: can.route.attr('hubId')}).then(function(data){
					var bits = self.attr('bits');
					bits.unshift.apply(bits, data);
				});
			}
		},
		events : {
			inserted : function(){
				var self = this;
				this.on(Models.Bit, 'created', function(ev, bit){
					self.scope.attr('bits').unshift(bit)
				})
			}
		}
	})
});