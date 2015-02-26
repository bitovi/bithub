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
			init : function(){
				var self = this;
				Models.Analytics.findAll({hubId: this.attr('state.hubId')}).then(function(data){
					self.attr('analytics', data);
				});
			}
		},
		helpers : {
			renderGraph : function(){
				var self = this;
				return function(el){
					var ctx = el.getContext('2d');
					var chart = new Chart(ctx).Line(self.attr('analytics').graphData(), {
						datasetFill: false,
						bezierCurve: false,
						pointDot: false
					})
				}
			},
			finalCount : function(timepoints){
				timepoints = can.isFunction(timepoints) ? timepoints() : timepoints;
				return timepoints[timepoints.length - 1].volume;
			}
		}
	})
})