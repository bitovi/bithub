import can from "can/";

import initView from './analytics.stache!';

import Models from "models/";

import "components/crawler_analytics/crawler_analytics";
import "components/interaction_analytics/interaction_analytics";
import "./analytics.less!";

can.Component.extend({
	tag: 'bh-analytics',
	template: initView,
	scope: {
		tab : 'interaction',
		init : function(){
			var self = this;
			Models.Hub.findOne({id: this.attr('state.hubId')}).then(function(hub){
				self.attr('hub', hub);
			});
		},
		switchTab : function(ctx, el){
			this.attr('tab', el.data('tab'));
		}
	}
});
