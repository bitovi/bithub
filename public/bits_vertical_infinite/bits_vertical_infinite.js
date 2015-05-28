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
	var width = el && el.width() || 0;
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
	init : function(source){
		this.attr({
			__allData : source || [],
			__columns : [],
			__currentColumn : 0,
			__currentPrependColumn : 0,
			__columnCount : 0,
			__limit : Infinity,
			__prependPaused: false,
		});

		if(source){
			source.on('add', this.proxy('replicateChangesFromSource'));
			source.on('remove', this.proxy('replicateChangesFromSource'));
		}
	},
	replicateChangesFromSource : function(ev, elements, index){
		var isPrependPaused = this.attr('__prependPaused');
		var what = ev.type;
		var isTail;

		if(what === 'add'){
			isTail = this.__allData.length - elements.length === index;
			if(isTail){
				this.append(elements);
			} else if(!isPrependPaused){
				if(index === 0){
					this.prependImmediately(elements);
				} else {
					can.batch.start();
					this.clearColumns();
					this.resetCurrentColumn();
					this.append();
					can.batch.stop();
				}
			} else if(isPrependPaused){
				this.attr('__dataAddedWhilePrependPaused', true);
			}
		} else if(what === 'remove'){
			this.removeItems(elements);
		}
	},
	removeItems : function(items){
		var columns = this.attr('__columns');
		var index;
		can.batch.start();
		for(var i = 0; i < items.length; i++){
			for(var j = 0; j < columns.length; j++){
				index = columns[j].indexOf(items[i]);
				if(index > -1){
					columns[j].splice(index, 1);
				}
			}
		}
		can.batch.stop();
	},
	clearColumns : function(){
		var columns = this.attr('__columns');
		for(var i = 0; i < columns.length; i++){
			columns[i].splice(0);
		}
	},
	resetCurrentColumn : function(){
		this.attr('__currentColumn', 0);
	},
	prependPaused : function(val){
		this.attr('__prependPaused', val);
		if(!val){
			this.attr({
				__currentPrependColumn: 0,
				__dataAddedWhilePrependPaused: false
			});
		}
	},
	columns : function(){
		return this.attr('__columns');
	},
	columnCount : function(){
		return this.attr('__columnCount');
	},
	limit : function(){
		return this.attr('__limit');
	},
	hasPending : function(){
		return !this.__pendingItems || this.__pendingItems.length === 0;
	},
	source : function(){
		return this.attr('__allData');
	},
	addPending : function(item){
		return item;
	},
	append : function(newData){
		var currentColumn = this.attr('__currentColumn');
		var columnCount = this.attr('__columnCount');
		var allData = this.attr('__allData');
		var columns = this.columns();
		var limit = this.attr('__limit');
		var calculateCurrent = makeCalculateCurrent(currentColumn, columnCount);
		var appendingData = newData ? newData : allData;

		can.batch.start();

		for(var i = 0; i < appendingData.length; i++){
			if(limit === Infinity || totalCount(columns) < limit){
				columns[currentColumn].push(this.addPending(appendingData[i]));
				currentColumn = calculateCurrent();
			}
		}

		this.attr('__currentColumn', currentColumn);
		can.batch.stop();
	},
	prependImmediately : function(newData){
		var columnCount = this.attr('__columnCount');
		var columns = this.columns();
		var currentPrependColumn = this.attr('__currentPrependColumn');
		var calculateCurrent = makeCalculateCurrent(currentPrependColumn, columnCount);
		var currentLimit = this.attr('__limit');
		can.batch.start();
		for(var i = 0; i < newData.length; i++){
			columns[currentPrependColumn].unshift(this.addPending(newData[i], true));
			currentPrependColumn = calculateCurrent();
		}
		this.attr('__currentPrependColumn', currentPrependColumn);
		this.attr('__limit', currentLimit + newData.length);
		can.batch.stop();
	},
	appendCb : function(){
		return (data) => { this.append(data); };
	},
	resetColumns : function(newColumnCount){
		var currentColumnCount = this.attr('__columnCount');
		newColumnCount = newColumnCount || this.attr('__columnCount');
		
		can.batch.start();
		this.attr({
			__currentColumn : 0,
			__columnCount : newColumnCount
		});
		
		if(currentColumnCount !== newColumnCount){
			this.attr('__columns').replace(makeColumns(newColumnCount));
		} else {
			this.clearColumns();
		}
		this.append();
		// We need to append current data to new columns
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
		
		can.batch.start();
		if(appendUntil >= currentLimit){
			for(i = currentLimit; i < appendUntil; i++){
				columns[currentColumn].push(this.addPending(allData[i]));
				currentColumn = calculateCurrent();
			}
			this.attr('__currentColumn', currentColumn);
		} else if(limit !== Infinity) {
			// Mutate column lists in place so we wouldn't trigger
			// CanJS live binding for columns. This way items that stay
			// in page won't be removed and then inserted again.
			perColumnAmount = makePerColumnAmount(columnCount, appendUntil);
			for(i = 0; i < columnCount; i++){
				columns[i].splice(perColumnAmount[i], columns[i].length);
			}
			
			currentColumn = (appendUntil % columnCount);
			if(currentColumn === columnCount){
				currentColumn = 0;
			}

			this.attr('__currentColumn', currentColumn);
		}
		this.attr('__limit', limit);
		can.batch.stop();
	},
	hasDataAfterLimit : function(){
		var allData = this.attr('__allData');
		var firstIndex = allData.indexOf(this.columns()[0][0]);
		var length = allData.length;
		var limit = this.attr('__limit');
		
		return (length - firstIndex - limit > 0);
	},
	resetFromTopIfNeeded : function(){
		this.attr('__limit', PER_PAGE);
		if(this.attr('__dataAddedWhilePrependPaused')){
			this.resetColumns();
		}
		this.prependPaused(false);
	}
});

var PartitionedColumnListWithDeferredRendering = PartitionedColumnList.extend({
	addPending : function(item, shouldUnshift){
		can.batch.start();
		item.attr('@pendingRender', true);

		this.__pendingItems = this.__pendingItems || [];

		if(shouldUnshift){
			this.__pendingItems.unshift(item);
		} else {
			this.__pendingItems.push(item);
		}
		
		clearTimeout(this.__renderPendingTimeout);
		this.__renderPendingTimeout = setTimeout(this.proxy('renderPending'), 1);
		can.batch.stop();
		return item;
	},
	renderPending : function(){
		var items = this.__pendingItems || [];
		var renderFn = function(){
			// We render items in batches of 5 so live binding setup
			// wouldn't block the scrolling.
			var toProcess = items.splice(0, 5);

			can.batch.start();
			for(var i = 0; i < toProcess.length; i++){
				toProcess[i].attr('@pendingRender', false);
			}
			can.batch.stop();

			if(items.length){
				setTimeout(renderFn, 1);
			}
		};
		setTimeout(renderFn, 1);
	}
});

export var BitsVerticalInfiniteVM = can.Map.extend({
	init : function(){
		this.attr('partitionedList', new PartitionedColumnListWithDeferredRendering(this.attr('bits')));
	}
});

can.Component.extend({
	tag : 'bh-bits-vertical-infinite',
	template : initView,
	scope : BitsVerticalInfiniteVM,
	events : {
		inserted : function(){
			this.calculateColumnCount();
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
					partitionedList.append();
				}
			}, 1);
		},
		nextPage : function(){
			var partitionedList = this.scope.attr('partitionedList');
			
			if(this.__minHeight === this.__minHeightTriggeredReq){
				return;
			}

			this.__minHeightTriggeredReq = this.__minHeight;
			
			if(partitionedList.hasDataAfterLimit()){
				partitionedList.setLimit(partitionedList.limit() + PER_PAGE);
			} else {
				partitionedList.setLimit(Infinity);
				this.element.trigger('bits:nextPage');
			}
		},
		scrollHandler : function(){
			var scrollTop = this.element.scrollTop();
			var scrollHeight = (this.__minHeight || this.element.prop('scrollHeight'));
			var height =  this.element.height();
			var partitionedList = this.scope.attr('partitionedList');
			var onBottom = scrollHeight - scrollTop - height < 400;
			var isLoading = this.scope.attr('isLoading');
			
			if(scrollTop === 0){
				partitionedList.resetFromTopIfNeeded();
				setTimeout(this.proxy('calculateMinHeight'), 1);
			} else {
				partitionedList.prependPaused(true);
				if(onBottom && !isLoading){
					this.nextPage();
				}
			}
		},
		calculateMinHeight : function(){
			if(!this.element){
				return;
			}
			var heights = can.map(this.element.find('.column'), function(c){
				return $(c).height();
			});

			var minHeight = Math.min.apply(Math, heights);
			delete this.__minHeightTriggeredReq;
			this.__minHeight = minHeight;
		},
		"bit:loaded" : 'calculateMinHeight'
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
