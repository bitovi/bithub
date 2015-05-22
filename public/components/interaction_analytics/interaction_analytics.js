import can from "can/";
import initView from "./interaction_analytics.stache!";
import InteractionEvent from "models/interaction_event";
import Chart from "chart";
import "./interaction_analytics.less!";

export var InteractionAnalyticsVM = can.Map.extend({
	init : function(){
		this.loadInteractionsData();
	},
	loadInteractionsData : function(){
		var self = this;
		InteractionEvent.findAll({event_type: 'share', zoom: 'rough'}).then(function(data){
			self.attr('totalShareInteractions', data);
		});
		InteractionEvent.findAll({event_type: 'share'}).then(function(data){
			self.attr('perNetworkShareInteractions', data);
		});
		InteractionEvent.findAll({event_type: 'link'}).then(function(data){
			self.attr('linkInteractions', data);
		});
		InteractionEvent.findAll({event_type: 'scroll'}).then(function(data){
			self.attr('scrollInteractions', data);
		});
	}
});

can.Component.extend({
	tag : 'bh-interaction-analytics',
	template: initView,
	scope: InteractionAnalyticsVM,
	helpers : {
		renderGraph : function(type){
			var self = this;
			var fnName;
			type = can.isFunction(type) ? type() : type;
			fnName = type + 'GraphData';
			return function(el){
				setTimeout(function(){
					var ctx = el.getContext('2d');
					var data = self.attr(type)[fnName]();
					new Chart(ctx).Line(data, {
						bezierCurveTension : 0.1,
						pointDotRadius: 2,
						datasetStrokeWidth: 2,
						multiTooltipTemplate: "<%=datasetLabel%> - <%= value %>"
					});
				}, 4);
			};
		}
	}
});
