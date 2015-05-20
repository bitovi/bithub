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
					$.when(
						this.analyticsReq(),
						Models.Hub.findOne({id: this.attr('state.hubId')})
					).then(function(analytics, hub){
						self.attr({
							analytics: analytics,
							hub: hub
						});
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
							var chart = new Chart(ctx).Line(self.attr('analytics').graphData(type), {
								bezierCurveTension: 0.1,
								pointDotRadius: 2,
								datasetStrokeWidth: 2,
								multiTooltipTemplate: "<%=datasetLabel%> - <%= value %> items",
							});
						}, 4);
					}
				},
				finalCount : function(timepoints){
					timepoints = can.isFunction(timepoints) ? timepoints() : timepoints;
					return (timepoints[timepoints.length - 1] || {volume: '0'}).volume;
				},
				hasEnoughData : function(opts){
					var analytics = this.attr('analytics');
					console.log(analytics.graphData('volume'))
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
