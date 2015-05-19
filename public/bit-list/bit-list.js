steal(
'can/control',
'./bit-list.stache!',
'models/bit.js',
'lodash/collections/map.js',
'can/construct/super',
'can/construct/proxy',
function(Control, initView, Bit, _map){

	var CARD_MIN_WIDTH = 300;

	var calculateColumnCount = function(el){
		var width = el.width();
		if(width < CARD_MIN_WIDTH) {
			return 1;
		}
		return Math.min(5, Math.floor(width / CARD_MIN_WIDTH));
	};

	var makeColumns = function(count){
		return _map(new Array(count), function(){
			return new can.List();
		});
	};

	var WINDOW_COUNT = 50;

	return Control.extend({
		pluginName : 'bh-bits',
	}, {
		setup : function(el, opts){
			opts = opts || {};
			opts.columnCount = can.compute(0);
			opts.isLoading   = can.compute(false);
			opts.hasNextPage = can.compute(true);
			opts.currentScrollTop = can.compute(0);
			return this._super(el, opts);
		},
		init : function(){
			this.__timeouts = {};
			this.__minHeight = 0;

			this.columns = new can.List();

			this.element.html(initView({
				isLoading : this.options.isLoading,
				columnCount : this.options.columnCount,
				state : this.options.state,
				columns : this.columns
			}));

			this.__hasItemsOnTop = false;

			this.updateColumnCount();
			this.load();
		},
		load : function(){
			var self = this;
			this.options.isLoading(true);

			this.__pendingReq = Bit.findAll(this.options.state.getParams()).then(function(data){
				var bits = self.options.state.attr('bits');

				can.batch.start();

				bits.push.apply(bits, data);
				self.options.isLoading(false);

				if(data.length < self.options.state.attr('params.limit')){
					self.options.hasNextPage(false);
				}

				self.currentLimit = self.currentLimit + data.length;
				self.partition(data);

				delete self.__pendingReq;

				can.batch.stop();
			});
		},
		updateColumnCount : function(){
			this.options.columnCount(calculateColumnCount(this.element));
		},
		'{window} resize' : function(){
			this.clearTimeout('windowResize');
			this.setTimeout('windowResize', 100, 'updateColumnCount');
		},
		'{columnCount} change' : function(compute, ev, newVal){
			this.resetColumns(newVal);
		},
		"{state.bits} partition" : function(){
			if(this.options.currentScrollTop() === 0){
				this.resetColumns(this.options.columnCount());
			}
		},
		"{currentScrollTop} change" : function(currentScrollTop, ev, newVal){
			if(newVal !== 0){
				return;
			}
			var columnCount = this.options.columnCount();
			var perColumns = can.map(new Array(columnCount), function(){ return 0; });
			var currentCount = 0;
			var i;
			
			this.currentColumn = 0;

			for(i = 0; i < WINDOW_COUNT; i++){
				perColumns[this.currentColumn]++;
				this.currentColumn++;
				currentCount++;
				if(this.currentColumn === columnCount){
					this.currentColumn = 0;
				}
			}

			can.batch.start();
			for(i = 0; i < columnCount; i++){
				this.columns[i].splice(perColumns[i], this.columns[i].length);
			}
			can.batch.stop();
			
			this.currentLimit = currentCount;
			setTimeout(this.proxy('calculateMinHeight'), 1);
		},
		resetColumns : function(columnCount){
			this.columns.replace(makeColumns(columnCount));
			this.currentColumn = 0;
			this.partitionFromTop(this.options.state.attr('bits'));
		},
		partitionFromTop : function(bits){
			this.currentLimit = 0;
			this.partitionPart(bits);
		},
		partitionPart : function(bits){
			this.partition(bits.slice(this.currentLimit, this.currentLimit + WINDOW_COUNT));
			this.currentLimit = this.currentLimit + WINDOW_COUNT;
		},
		partition : function(bits){
			var columnLength = this.columns.length;
			var self = this;
			var start = 0;
			var partitionFn = function(){
				var end = start + 5;

				if(bits.length < end){
					end = bits.length;
				}

				can.batch.start();
				for(var i = start; i < end; i++){
					self.columns[self.currentColumn].push(bits[i]);
					self.currentColumn++;
					if(self.currentColumn >= columnLength){
						self.currentColumn = 0;
					}
				}
				can.batch.stop();
				
				if(end < bits.length){
					start = end;
					setTimeout(partitionFn, 1);
				}
				self.calculateMinHeight();
			};

			partitionFn();

		},
		nextPage : function(){
			var params;
			var bits = this.options.state.attr('bits');

			if(this.currentLimit < bits.length){
				this.partitionPart(bits);
			} else if(!this.options.isLoading() && this.options.hasNextPage()){
				params = this.options.state.attr('params');
				params.attr('offset', this.options.state.attr('bits.length'));
				this.load();
			}
		},
		appendContent : function(){
			var self = this;
			this.clearTimeout('appendContent');
			
			this.setTimeout('appendContent', 100, function(){
				var scrollTop = self.element.scrollTop();
				var scrollHeight = self.__minHeight || self.element.prop('scrollHeight');
				var height =  self.element.height();

				self.options.currentScrollTop(scrollTop);

				if(scrollHeight - scrollTop - height < 500){
					self.nextPage();
				}
			});
		},
		scroll : 'appendContent',
		clearTimeout : function(name){
			clearTimeout(this.__timeouts[name]);
			delete this.__timeouts[name];
		},
		setTimeout : function(name, timeout, fn){
			if(typeof fn === 'string'){
				fn = this.proxy(fn);
			}
			this.__timeouts[name] = setTimeout(fn, timeout);
		},
		clearAllTimeouts : function(){
			for(var k in this.__timeouts){
				this.clearTimeout(k);
			}
		},
		clearPendingReq : function(){
			if(this.__pendingReq){
				this.__pendingReq.abort();
			}
		},
		destroy : function(){
			this.clearAllTimeouts();
			return this._super.apply(this, arguments);
		},
		"bit:loaded" : 'calculateMinHeight',
		calculateMinHeight : function(){
			if(!this.element){
				return;
			}

			var heights = can.map(this.element.find('.column'), function(c){
				return $(c).height();
			});
			var minHeight = Math.min.apply(Math, heights);
			this.__minHeight = minHeight;
		}
	});
});
