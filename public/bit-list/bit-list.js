steal(
'can/control',
'./bit-list.stache!',
'models/bit.js',
'lodash/collections/map.js',
'can/construct/super',
'can/construct/proxy',
function(Control, initView, Bit, _map){

	var CARD_MIN_WIDTH = 300;
	var CARD_TEMPLATE = can.stache('<bh-bit bit="{bit}" state="{state}" class="animate-height loading"></bh-bit>');

	var calculateColumnCount = function(el){
		var width = el.width();
		if(width < CARD_MIN_WIDTH) {
			return 1;
		}
		return Math.min(5, Math.floor(width / CARD_MIN_WIDTH));
	}

	var makeColumns = function(count){
		return _map(Array(count), function(){
			return $('<div class="column"></div>');
		});
	}


	var WINDOW_COUNT = 30;

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

			this.element.html(initView({
				isLoading : this.options.isLoading,
				columnCount : this.options.columnCount,
				state : this.options.state
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
			if(newVal === 0){
				this.resetColumns(this.options.columnCount());
			}
		},
		resetColumns : function(columnCount){
			this.columns = makeColumns(columnCount);
			this.currentColumn = 0;
			this.partitionFromTop(this.options.state.attr('bits'));
			this.element.find('.column-wrapper').html(this.columns);
		},
		'{state.bits} remove' : function(bits, ev, removed){
			for(var i = 0; i < removed.length; i++){
				$(this.__cardCache[removed[i].id]).remove();
				delete this.__cardCache[removed[i].id];
			}
		},
		partitionFromTop : function(bits){
			this.currentStart = 0;
			this.currentLimit = WINDOW_COUNT;
			this.partitionPart(bits);
		},
		partitionPart : function(bits){
			this.partition(bits.slice(this.currentStart, this.currentLimit));
		},
		partition : function(bits){

			var columnLength = this.columns.length;
			var arrs = _map(Array(columnLength), function(){
				return [];
			});
			var card;

			for(var i = 0; i < bits.length; i++){
				card = this.makeCard(bits[i]);
				if(card){
					arrs[this.currentColumn].push(card);
					this.currentColumn++;
					if(this.currentColumn === columnLength){
						this.currentColumn = 0;
					}
				}
			}


			for(var i = 0; i < arrs.length; i++){
				this.columns[i].append(arrs[i]);
			}
		},
		makeCard : function(bit){
			var id = bit.attr('id');

			this.__cardCache = this.__cardCache || {};

			if(!this.__cardCache[id]){
				this.__cardCache[id] = CARD_TEMPLATE({
					bit: bit,
					state: this.options.state
				}).firstChild;
			}
			return this.__cardCache[id];
		},
		nextPage : function(){
			var params;
			var bits = this.options.state.attr('bits');
			if(this.currentLimit < bits.length){
				this.currentStart = this.currentLimit;
				this.currentLimit = this.currentLimit + WINDOW_COUNT;
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
				var scrollHeight = self.element.prop('scrollHeight');
				var height = self.element.height();

				self.options.currentScrollTop(scrollTop);

				(scrollHeight - scrollTop - height < 500) && self.nextPage();
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
			this.__pendingReq && this.__pendingReq.abort();
		},
		destroy : function(){
			this.clearAllTimeouts();
			return this._super.apply(this, arguments);
		}
	});
})