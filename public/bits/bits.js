steal(
'can/component',
'./bits.stache!',
'models',
'./bits.less!',
'can/map/define',
'components/service-loader',
'bit',
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
			},
			belowTheFoldCounter : 0
		},
		events : {
			'{state} scrollTop' : 'recalculateBelowTheFold',
			'{state} scrollHeight' : 'recalculateBelowTheFold',
			"bh-bit bitInserted" : function(el){
				this.isBelowTheFold(el);
			},
			isBelowTheFold : function(el){
				var top            = el.offset().top,
					scrollPosition = parseInt(this.scope.attr('state.scrollTop')),
					scrollHeight   = parseInt(this.scope.attr('state.scrollHeight')); 

				if(top > scrollPosition + scrollHeight){
					el.addClass('below-the-fold');
				} else {
					el.removeClass('below-the-fold');
				}

				this.scope.attr('belowTheFoldCounter', this.element.find('bh-bit.below-the-fold').length);
			},
			recalculateBelowTheFold : function(){
				var self = this;
				clearTimeout(this.__recalculateTimeout);

				this.__recalculateTimeout = setTimeout(function(){
					self.element.find('bh-bit.below-the-fold').each(function(){
						self.isBelowTheFold($(this));
					})
				}, 100);
			}
		}
	})
});