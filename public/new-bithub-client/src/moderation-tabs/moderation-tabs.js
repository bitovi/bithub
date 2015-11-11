import can from "can";
import template from "./moderation-tabs.stache!";

import "./moderation-tabs.less!";
import "can/route/";

const ICON_MAPPINGS = {
	pending: 'inbox',
	approved: 'thumbs-up',
	starred: 'star',
	deleted: 'trash'
};


export default can.Component.extend({
	tag: 'bh-moderation-tabs',
	template: template,
	scope : {
		icon : function(icon){
			var color = this.attr('activeTab') === icon ? "white" : "grey";
			return "images/app-resources-icons-" + (ICON_MAPPINGS[icon] || icon) + "-" + color + ".svg";
		},
		countFor : function(decision){
			var entityDecisions = this.attr('entityDecisions');
			if(entityDecisions.isResolved()){
				return "(" + entityDecisions.getById(decision).attr('count') + ")";
			}
		}
	},
	helpers : {
		moderationUrl : function(tab){
			tab = can.isFunction(tab) ? tab() : tab;
			return can.route.url({moderationTab: tab}, true);
		}
	}
});

