steal('can/model', 'moment', function(Model, moment){
	var Analytics = Model.extend({
		findAll : '/api/v3/analytics/services?resolution=minute&embed_id={hubId}'
	}, {

	});

	var fillInMissingTimepoints = function(points, length){
		while(points.length < length){
			points.unshift(0);
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

			for(var i = 0; i < length; i++){
				service = this.attr(i + '.source');
				timepoints = this.attr(i + '.timepoints');
				
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
					fillColor: "rgba(220,220,220,0.2)",
					strokeColor: "rgba(220,220,220,1)",
					pointColor: "rgba(220,220,220,1)",
					pointStrokeColor: "#fff",
					pointHighlightFill: "#fff",
					pointHighlightStroke: "rgba(220,220,220,1)",
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