import can from "can";
import template from "./moderation-card.stache!";
import "./moderation-card.less!";

const ACTION_ICON_MAP = {
	approve : 'thumbs-up',
	destroy : 'trash'
};

export default can.Component.extend({
	tag: 'bh-moderation-card',
	template: template,
	scope : {
		iconUrl : function(action){
			var icon = ACTION_ICON_MAP[action] || action;
			return "images/app-resources-icons-" + icon + '-white.svg';
		}
	}
});
