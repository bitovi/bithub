import can from "can";
import template from "./moderation-card.stache!";
import "./moderation-card.less!";

const DECISION_ICON_MAP = {
	approved  : 'thumbs-up',
	deleted   : 'trash',
	starred   : 'star'
};


export default can.Component.extend({
	tag: 'bh-moderation-card',
	template: template,
	scope : {
		iconUrl : function(decision){
			var icon = DECISION_ICON_MAP[decision] || decision;
			var color = 'white';

			if(decision === this.attr('bit.decision')){
				color = 'grey';
			}

			return "images/app-resources-icons-" + icon + '-' + color + '.svg';
		}
	}
});
