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
			},
			init : function(){
				
			},
			reload : function(){
				console.log('RELOAD')
				var self = this;
				setTimeout(function(){
					Models.Bit.findAll({hubId: can.route.attr('hubId')}).then(function(data){
						self.attr('bits').replace(data);
						self.reload();
					});
				}, 10000)
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