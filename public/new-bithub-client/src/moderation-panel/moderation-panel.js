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
		"{scope.Bit} updated" : function(Bit, ev, bit){
			var bitDecision = bit.attr('decision');
			var activeDecision = this.scope.attr('activeDecision');
			var bits = this.scope.attr('bits');
			var bitElement = this.element.find('[data-bit-id=' + bit.id + ']');
			if(bitDecision !== activeDecision){
				setTimeout(function(){
					bitElement.slideUp(300, function(){
						bits.remove(bit);
					});
				}, 1000);
				
			}
		}
	}
});
