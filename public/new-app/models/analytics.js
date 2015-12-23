import can from "can";
import Service from "./service";
import moment from "moment";

import "can/map/define/";
import "components/service-config-formatter/";

var TOOLTIP = can.stache('<bh-service-config-formatter service="{this}"></bh-service-config-formatter>');

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
};

var alphaVersion = function(color){
	return 'rgba' + color.substring(3, color.length - 1) + ', .2)';
};

var Analytics = can.Model.extend({
	findAll : '/api/v3/analytics?source_type={sourceType}&resolution={resolution}&owner_id={ownerId}'
}, {
	define : {
		source : {
			Type: Service
		}
	}
});

Analytics.List = Analytics.List.extend({
	graphData : function(type){
		var length = this.attr('length');
		var serviceTimepoints = {};
		var service;
		var timepoints;
		var isLongest = false;
		var data = [];
		var longestPointsLengthLabels = [];
		var i;

		for(i = 0; i < length; i++){
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

		for(i = 0; i < length; i++){
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
		};
	}
});

export default Analytics;
