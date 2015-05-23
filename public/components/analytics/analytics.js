import can from "can/";

import initView from './analytics.stache!';

import "components/crawler_analytics/crawler_analytics";
import "components/interaction_analytics/interaction_analytics";
import "./analytics.less!";

can.Component.extend({
	tag: 'bh-analytics',
	template: initView,
	scope: {
		tab : 'interaction',
		switchTab : function(ctx, el){
			this.attr('tab', el.data('tab'));
		}
	}
});
