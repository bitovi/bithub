steal(
'can/component',
'./analytics.stache!',
'chart',
'models',
'./analytics.less!',
'components/service-config-formatter',
function(Component, initView, Chart, Models){

	return Component.extend({
		tag : 'bh-analytics',
		template: initView,
		scope : {
			resolution: 'hour',
			init : function(){
				var self = this;
				var hubId = this.attr('state.hubId');

				$.when(
					Models.Analytics.findAll({hubId: hubId, resolution: this.attr('resolution')}),
					Models.Hub.findOne({id: hubId})
				).then(function(analytics, hub){
					self.attr({
						analytics: analytics,
						hub: hub
					});
				});
			},
			reloadAnalytics : function(){
				var self = this;

				Models.Analytics.findAll({
					hubId: this.attr('state.hubId'),
					resolution: this.attr('resolution')
				}).then(function(data){
					self.attr('analytics', data);
				});
			}
		},
		helpers : {
			renderGraph : function(type){
				var self = this;

				type = can.isFunction(type) ? type() : type;

				return function(el){
					var ctx = el.getContext('2d');
					var chart = new Chart(ctx).Line(self.attr('analytics').graphData(type), {
						bezierCurveTension: 0.1,
						pointDotRadius: 2,
						datasetStrokeWidth: 2,
						multiTooltipTemplate: "<%=datasetLabel%> - <%= value %> items",
					})
				}
			},
			finalCount : function(timepoints){
				timepoints = can.isFunction(timepoints) ? timepoints() : timepoints;
				return (timepoints[timepoints.length - 1] || {volume: '0'}).volume;
			},
			hasEnoughData : function(opts){
				var analytics = this.attr('analytics');
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
	})
})