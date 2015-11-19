import can from "can";
import template from "./moderation-card.stache!";
import "./moderation-card.less!";

const DECISION_ICON_MAP = {
	approved  : 'thumbs-up',
	deleted   : 'trash',
	starred   : 'star'
};

var removeHtmlTags = function(html){
	return (html || "").replace(/<[^>]+>/ig, "");
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
		},
		feedIconUrl : function(feedName){
			return "images/social-grey/" + feedName + ".png";
		},
		shouldBeColumns : function(){
			var bit = this.attr('bit');
			var hasImages = !!bit.attr('images').attr('length');
			var bodyLength = removeHtmlTags(bit.attr('body')).length;
			var titleLength = removeHtmlTags(bit.attr('title')).length;
			if(hasImages){
				if(bodyLength + titleLength > 300){
					return false;
				}
				return true;
			}
			return false;
		}
	},
	helpers : {
		formattedTitle : function(title){
			title = can.isFunction(title) ? title() : title;
			if(title && title !== 'undefined'){
				return title;
			}
			return "";
		},
		formattedQuotedTweetDate : function(date){
			date = can.isFunction(date) ? date() : date;
			return moment(date, 'dd MMM DD HH:mm:ss ZZ YYYY').format('LL');
		}
	},
	events : {
		inserted : function(){
			this.element.find('.content-column--title-body img').wrap('<div class="content-image-wrap"></div>');
		}
	}
});
