import can from "can";
import steal from "@steal";

can.Component.extend({
	tag: 'bh-slideout',
	events: {
		inserted : function(){
			setTimeout(()=> this.initSlideout(), 1);
		},
		'.toggle-button click' : function(){
			if(this.slideout){
				this.slideout.toggle();
			}
		},
		initSlideout : function(){
			var self = this;
			if(window && window.navigator){
				steal.done().then(function(){
					steal('slideout/dist/slideout.js', function(Slideout){
						if(!self.element){
							return;
						}
						self.slideout = new Slideout({
							'panel': self.element.find('#panel')[0],
							'menu': self.element.find('#menu')[0],
							'padding': 256,
							'tolerance': 70
						});
					});
				});
			}
			
		}
	}
});
