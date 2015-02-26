steal(
'can/model',
'./service.js',
'moment',
'randomcolor',
'can/map/define',
function(Model, Service, moment, randomColor){
	var Analytics = Model.extend({
		findAll : '/api/v3/analytics/services?resolution=minute&embed_id={hubId}'
	}, {
		define : {
			source : {
				Type: Service
			}
		}
	});

	var fillInMissingTimepoints = function(points, length){
		while(points.length < length){
			points.unshift(null);
		}
		return points;
	}

	Analytics.List = Analytics.List.extend({
		graphData : function(){
			var length = this.attr('length');
			var dates = [];
			var serviceTimepoints = {};
			var service;
			var timepoints;
			var isLongest = false;
			var data = [];
			var longestPointsLengthLabels = [];
			var randomColors = randomColor({
				count: length,
				hue: 'random'
			})

			for(var i = 0; i < length; i++){
				service = this.attr(i + '.source');
				timepoints = this.attr(i + '.timepoints');

				service.attr('graphColor', randomColors.pop());
				
				serviceTimepoints[service.id] = [];

				isLongest = (timepoints.length > longestPointsLengthLabels.length);

				if(isLongest){
					longestPointsLengthLabels = [];
				}

				for(var j = 0; j < timepoints.length; j++){
					serviceTimepoints[service.id].push(timepoints[j].volume);
					longestPointsLengthLabels.push(moment(timepoints[j].measured_at).fromNow());
				}
			}

			for(var k in serviceTimepoints){
				serviceTimepoints[k] = fillInMissingTimepoints(serviceTimepoints[k], longestPointsLengthLabels.length);
			}

			for(var i = 0; i < length; i++){
				service = this.attr(i + '.source');
				data.push({
					label : service.type_name,
					fillColor: service.attr('graphColor'),
					strokeColor: service.attr('graphColor'),
					pointColor: service.attr('graphColor'),
					pointHighlightFill: "#fff",
					pointHighlightStroke: service.attr('graphColor'),
					data: serviceTimepoints[service.id]
				});
			}

			return {
				labels : longestPointsLengthLabels,
				datasets: data
			}
		}
	});

	return Analytics;
});