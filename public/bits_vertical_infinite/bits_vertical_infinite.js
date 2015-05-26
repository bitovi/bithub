import can from "can/";
import initView from "./bits_vertical_infinite.stache!";
import _map from "lodash/collections/map";
import _reduce from "lodash/collections/reduce";
import _throttle from "lodash/functions/throttle";

import "./bits_vertical_infinite.less!";
import "can/construct/proxy/";

var CARD_MIN_WIDTH = 300;
var PER_PAGE = 50;


var calculateColumnCount = function(el){
	var width = el.width();
	if(width < CARD_MIN_WIDTH) {
		return 1;
	}
	return Math.min(5, Math.floor(width / CARD_MIN_WIDTH));
};

var makeColumns = function(count){
	return _map(Array(count), () => { return []; });
};


var makeCalculateCurrent = function(currentColumn, columnCount){
	return function(){
		currentColumn++;
		if(currentColumn === columnCount){
			currentColumn = 0;
		}
		return currentColumn;
	};
};

var makePerColumnAmount = function(columnCount, limit){
	var columns = _map(Array(columnCount), () => { return 0; });
	var currentColumn = 0;
	var calculateCurrent = makeCalculateCurrent(0, columnCount);

	for(var i = 0; i < limit; i++){
		columns[currentColumn]++;
		currentColumn = calculateCurrent();
	}

	return columns;
};

var totalCount = function(columns){
	return _reduce(columns, (acc, c) => { return acc + c.length; }, 0);
};

export var PartitionedColumnList = can.Map.extend({
	init : function(){
		this.attr({
			__allData : [],
			__columns : [],
			__currentColumn : 0,
			__columnCount : 0,
			__limit : Infinity
		});
	},
	append : function(newData){
		var currentColumn = this.attr('__currentColumn');
		var columnCount = this.attr('__columnCount');
		var allData = this.attr('__allData');
		var columns = this.columns();
		var limit = this.attr('__limit');
		var calculateCurrent = makeCalculateCurrent(currentColumn, columnCount);
		var appendingData;

		can.batch.start();
		
		if(newData){
			// First we append all data to the internal list
			allData.push.apply(allData, newData);
			appendingData = newData;
		} else {
			appendingData = allData;
		}


		for(var i = 0; i < appendingData.length; i++){
			if(limit === Infinity || totalCount(columns) < limit){
				columns[currentColumn].push(appendingData[i]);
				currentColumn = calculateCurrent();
			}
		}

		this.attr('__currentColumn', currentColumn);
		can.batch.stop();
	},
	prepend : function(newData){
		var allData = this.attr('__allData');
		allData.unshift.apply(allData, newData);
	},
	prependImmediately : function(newData){
		var columnCount = this.attr('__columnCount');
		var columns = this.columns();
		var currentColumn = 0;

		can.batch.start();
		for(var i = 0; i < newData.length; i++){
			columns[currentColumn].unshift(newData[i]);
			currentColumn++;
			if(currentColumn === columnCount){
				currentColumn = 0;
			}
		}
		this.prepend(newData);
		can.batch.stop();
	},
	columns : function(){
		return this.attr('__columns');
	},
	columnCount : function(){
		return this.attr('__columnCount');
	},
	limit : function(){
		return this.attr('limit');
	},
	appendCb : function(){
		return (data) => { this.append(data); };
	},
	resetColumns : function(newColumnCount){
		newColumnCount = newColumnCount || this.attr('__columnCount');
		
		can.batch.start();
		this.attr({
			__currentColumn : 0,
			__columnCount : newColumnCount
		});
		this.attr('__columns').replace(makeColumns(newColumnCount));
		// We need to append current data to new columns
		this.append();
		can.batch.stop();
	},
	resetColumnsAndAppend : function(newColumnCount, data){
		can.batch.start();
		this.resetColumns(newColumnCount);
		this.append(data);
		can.batch.stop();
	},
	setLimit : function(limit){
		var columns = this.columns();
		var columnCount = this.attr('__columnCount');
		var currentLimit = this.attr('__limit');
		var currentColumn = this.attr('__currentColumn');
		var calculateCurrent = makeCalculateCurrent(currentColumn, columnCount);
		var allData = this.attr('__allData');
		var appendUntil = limit > allData.length ? allData.length : limit;
		var perColumnAmount, i;

		console.log('APPEND UNTIL', appendUntil);
		//return;
		
		can.batch.start();
		if(appendUntil >= currentLimit){
			for(i = currentLimit; i < appendUntil; i++){
				columns[currentColumn].push(allData[i]);
				currentColumn = calculateCurrent();
			}
			this.attr('__currentColumn', currentColumn);
		} else {
			perColumnAmount = makePerColumnAmount(columnCount, appendUntil);
			for(i = 0; i < columnCount; i++){
				columns[i].splice(perColumnAmount[i], columns[i].length);
			}
		}
		this.attr('__limit', limit);
		can.batch.stop();
	},
	hasDataAfterLimit : function(){
		var allData = this.attr('__allData');
		var firstIndex = allData.indexOf(this.columns()[0][0]);
		var length = allData.length;
		var limit = this.attr('__limit');
		
		console.log('HAS DATA AFTER', (length - firstIndex - limit > 0))

		return (length - firstIndex - limit > 0);
	}
});

export var BitsVerticalInfiniteVM = can.Map.extend({
	init : function(){
		this.attr('partitionedList', new PartitionedColumnList());
	}
});

can.Component.extend({
	tag : 'bh-bits-vertical-infinite',
	template : initView,
	scope : BitsVerticalInfiniteVM,
	events : {
		inserted : function(){
			this.calculateColumnCount();
			this.requestData();

			this.element.on('scroll', _throttle(this.proxy('scrollHandler'), 200));

		},
		"{window} resize" : "calculateColumnCount",
		calculateColumnCount : function(){
			setTimeout(() => {
				var partitionedList = this.scope.attr('partitionedList');
				var currentColumnCount = partitionedList.columnCount();
				var newColumnCount =  calculateColumnCount(this.element);
				
				if(currentColumnCount !== newColumnCount){
					partitionedList.resetColumns(newColumnCount);
				}
			}, 1);
		},
		requestData : function(){
			this.element.trigger('bits:loadData', [this.scope.attr('partitionedList').appendCb()]);
		},
		nextPage : function(){
			var partitionedList = this.scope.attr('partitionedList');
			if(partitionedList.hasDataAfterLimit()){
				partitionedList.setLimit(partitionedList.limit() + PER_PAGE);
			} else {
				partitionedList.setLimit(Infinity);
				this.element.trigger('bits:nextPage', [partitionedList.appendCb()]);
			}
		},
		scrollHandler : function(){
			var scrollTop = this.element.scrollTop();
			var scrollHeight = (
				this.__minHeight || this.element.prop('scrollHeight')
			);
			var height =  this.element.height();

			if(scrollHeight - scrollTop - height < 500){
				this.nextPage();
			}
		},
		"bit:loaded" : function(){
			if(!this.element){
				return;
			}
			var heights = can.map(this.element.find('.column'), function(c){
				return $(c).height();
			});
			var minHeight = Math.min.apply(Math, heights);
			this.__minHeight = minHeight;
		}
	},
	helpers : {
		eachColumn : function(opts){
			var partitioned = this.attr('partitionedList');
			var columns = partitioned.columns();
			var columnCount = partitioned.columnCount(); 
			var result = [];
			for(var i = 0; i < columnCount; i++){
				result.push(opts.fn(opts.scope.add({items: columns[i]})));
			}
			return result;
		}
	}
});
