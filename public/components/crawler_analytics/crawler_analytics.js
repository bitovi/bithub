import can from "can/";
import initView from "./crawler_analytics.stache!";
import Chart from "chart.js/Chart";
import Models from "models/";

import "./crawler_analytics.less!";
import "components/service-config-formatter/";

can.Component.extend({
	tag : 'bh-crawler-analytics',
	template: initView,
	scope : {
		resolution: 'hour',
		init : function(){
			var self = this;
			this.analyticsReq().then(function(analytics){
				self.attr('analytics', analytics);
			});
		},
		analyticsReq : function(){
			var hubId = this.attr('state.hubId');
			return Models.Analytics.findAll({
				ownerId: hubId,
				sourceType: 'services',
				resolution: this.attr('resolution')
			});
		},
		reloadAnalytics : function(){
			var self = this;

			this.analyticsReq().then(function(data){
				self.attr('analytics', data);
			});
		}
	},
	helpers : {
		renderGraph : function(type){
			var self = this;
			type = can.isFunction(type) ? type() : type;
			return function(el){
				setTimeout(function(){
					var ctx = el.getContext('2d');
					new Chart(ctx).Line(self.attr('analytics').graphData(type), {
						bezierCurveTension: 0.1,
						pointDotRadius: 2,
						datasetStrokeWidth: 2,
						multiTooltipTemplate: "<%=datasetLabel%> - <%= value %> items",
					});
				}, 4);
			};
		},
		finalCount : function(timepoints){
			timepoints = can.isFunction(timepoints) ? timepoints() : timepoints;
			return (timepoints[timepoints.length - 1] || {volume: '0'}).volume;
		},
		hasEnoughData : function(opts){
			var analytics = this.attr('analytics');
			console.log(analytics.graphData('volume'));
			if(analytics && analytics.graphData('volume').labels.length > 1){
				return opts.fn();
			}
			return opts.inverse();
		}
	},
	events : {
		'{scope} resolution' : function(){
			this.scope.reloadAnalytics();
		}
	}
});
