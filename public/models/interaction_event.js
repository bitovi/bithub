import can from "can/";
import moment from "moment";
import "can/construct/super/";

var wrapCreate = function(data){
	return {
		interaction: data
	};
};

var InteractionEvent = can.Model.extend({
	create : 'POST /api/v3/interactions',
	findAll : 'GET /api/v3/interactions',
	
	createScrollInteraction : function(tenant_name, hubId){
		return this.create(wrapCreate({
			tenant_name: tenant_name,
			primary_source_id: hubId,
			primary_source_type: 'Embed',
			event_type: 'scroll'
		}));
	},
	createLinkClickedInteraction : function(tenant_name, hubId, entityId){
		return this.create(wrapCreate({
			tenant_name: tenant_name,
			primary_source_id: hubId,
			primary_source_type: 'Embed',
			secondary_source_id: entityId,
			secondary_source_type: 'Entity',
			event_type: 'link'
		}));
	},
	createEntitySharedInteraction : function(tenant_name, hubId, entityId, target){
		return this.create(wrapCreate({
			tenant_name: tenant_name,
			primary_source_id: hubId,
			primary_source_type: 'Embed',
			secondary_source_id: entityId,
			secondary_source_type: 'Entity',
			event_type: 'share',
			event_subtype: target
		}));
	}
}, {});

var fillZeroes = function(data, length){
	while(data.length < length){
		data.unshift(0);
	}
	return data;
};

InteractionEvent.List = InteractionEvent.List.extend({
	totalShareInteractionsGraphData: function(){
		var length = this.attr('length');
		var labels = [];
		var data = [];
		var i;
		for(i = 0; i < length; i++){
			labels.push(moment(this.attr(i + '.created_at')).fromNow());
			data.push(this.attr(i + '.volume'));
		}

		return {
			datasets: [{
				data: data,
				label: "Share count",
				strokeColor: '#f30',
				fillColor: '#fff'
			}],
			labels: labels
		};
	},
	linkInteractionsGraphData : function(){
		return this.totalShareInteractionsGraphData();
	},
	scrollInteractionsGraphData : function(){
		return this.totalShareInteractionsGraphData();
	},
	perNetworkShareInteractionsGraphData : function(){
		var length = this.attr('length');
		var labels = {};
		var data = {};
		var longestLabels = [];
		var datasets = [];
		var i, k, current, currentSubtype;
		
		for(i = 0; i < length; i++){
			current = this.attr(i);
			currentSubtype = current.attr('event_subtype');
			if(!data[currentSubtype]){
				data[currentSubtype] = [];
			}
			if(!labels[currentSubtype]){
				labels[currentSubtype] = [];
			}
			data[currentSubtype].push(current.attr('volume'));
			labels[currentSubtype].push(moment(current.attr('created_at')).fromNow());
		}

		for(k in labels){
			if(labels[k].length > longestLabels.length){
				longestLabels = labels[k];
			}
		}

		for(k in data){
			if(data[k].length < longestLabels.length){
				data[k] = fillZeroes(data[k], longestLabels.length);
			}
			datasets.push({
				label: k,
				data: data[k],
				strokeColor: '#f30',
				fillColor: 'rgba(255,255,255,0)'
			});
		}

		return {
			labels: longestLabels,
			datasets: datasets
		};
		
	}
});

export default InteractionEvent;
