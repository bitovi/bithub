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
