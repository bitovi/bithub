import can from "can";
import Slideout from "slideout/dist/slideout";

can.Component.extend({
	tag: 'bh-slideout',
	events: {
		inserted : function(){
			setTimeout(()=> this.initSlideout(), 1);
		},
		'.toggle-button click' : function(){
			if(this.slideout){
				this.scope.attr('isOpen', !this.scope.attr('isOpen'));
				this.slideout.toggle();
			}
		},
		initSlideout : function(){
			var self = this;
			if(Slideout && self.element){
				self.slideout = new Slideout({
					'panel': self.element.find('#panel')[0],
					'menu': self.element.find('#menu')[0],
					'padding': 256,
					'tolerance': 70
				});
			}
		}
	}
});
