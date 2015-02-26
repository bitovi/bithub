steal(
'can/model',
'./service.js',
'moment',
'can/map/define',
'components/service-config-formatter',
function(Model, Service, moment){

	var TOOLTIP = can.stache('<bh-service-config-formatter service="{this}"></bh-service-config-formatter>');

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

		var firstRun = true;
		while(points.length < length){
			if(firstRun){
				points.unshift(0);
				firstRun = false;
			} else {
				points.unshift(null);
			}
			
		}
		return points;
	}

	var alphaVersion = function(color){
		return 'rgba' + color.substring(3, color.length - 1) + ', .2)';
	}

	Analytics.List = Analytics.List.extend({
		graphData : function(type){
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
					serviceTimepoints[service.id].push(timepoints[j][type]);
					if(isLongest){
						longestPointsLengthLabels.push(moment(timepoints[j].measured_at).fromNow());
					}
					
				}
			}

			for(var k in serviceTimepoints){
				serviceTimepoints[k] = fillInMissingTimepoints(serviceTimepoints[k], longestPointsLengthLabels.length);
			}

			for(var i = 0; i < length; i++){
				service = this.attr(i + '.source');
				data.push({
					label : can.trim(TOOLTIP(service).firstChild.innerText),
					fillColor: alphaVersion(service.attr('graphColor')),
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