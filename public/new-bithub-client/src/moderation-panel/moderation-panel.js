import can from "can";
import template from "./moderation-panel.stache!";
import Bit from "src/models/bit";
import "./moderation-panel.less!";

export default can.Component.extend({
	tag: 'bh-moderation-panel',
	template: template,
	scope : {
		Bit: Bit
	},
	events : {
		init : function(){
			this.__timeouts = {};
		},
		scroll : function(){
			var self = this;
			clearTimeout(this.__scrollTimeout);
			if(this.scope.bits.length){
				this.__scrollTimeout = setTimeout(function(){
					var scrollTop = self.element.scrollTop();
					var scrollHeight = self.element[0].scrollHeight;
					var height = self.element.outerHeight();
					if(scrollHeight - height - scrollTop < 200){
						self.scope.bits.loadNextPage();
					}
				}, 200);
			}
			
		},
		"{scope.Bit} updated" : function(Bit, ev, bit){
			var bitDecision = bit.attr('decision');
			var activeDecision = this.scope.attr('activeDecision');
			var id = bit.id;
			var bits = this.scope.attr('bits');
			var bitElement = this.element.find('[data-bit-id=' + id + ']');
			if(bitDecision !== activeDecision){
				clearTimeout(this.__timeouts[id]);
				this.__timeouts[id] = setTimeout(function(){
					bitElement.slideUp(300, function(){
						bits.remove(bit);
					});
				}, 1000);
			}
		}
	}
});
