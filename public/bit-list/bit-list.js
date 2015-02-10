steal(
'can/control',
'./bit-list.stache!',
'models/bit.js',
'lodash/collections/map.js',
'can/construct/super',
'can/construct/proxy',
function(Control, initView, Bit, _map){

	var CARD_MIN_WIDTH = 300;
	var CARD_TEMPLATE = can.stache('<bh-bit bit="{bit}" state="{state}"></bh-bit>');

	var calculateColumnCount = function(el){
		if(el.width < CARD_MIN_WIDTH) {
			return 1;
		}
		return Math.min(5, Math.floor(el.width() / CARD_MIN_WIDTH));
	}

	var makeColumns = function(count){
		return _map(Array(count), function(){
			return $('<div class="column"></div>');
		});
	}


	return Control.extend({
		pluginName : 'bh-bits',
	}, {
		setup : function(el, opts){
			opts = opts || {};
			opts.columnCount = can.compute(0);
			opts.isLoading   = can.compute(false);
			opts.hasNextPage = can.compute(true);
			opts.params      = new can.Map({
				offset: 0,
				limit: 15,
				order: "created_at:desc"
			});
			return this._super(el, opts);
		},
		init : function(){
			this.__timeouts = {};

			this.element.html(initView({
				isLoading : this.options.isLoading,
				columnCount : this.options.columnCount
			}));

			this.updateColumnCount();
			this.load();
		},
		load : function(){
			var self = this;
			this.options.isLoading(true);

			Bit.findAll(this.getParams()).then(function(data){
				var bits = self.options.state.attr('bits');

				can.batch.start();

				bits.push.apply(bits, data);
				self.options.isLoading(false);

				if(data.length < self.options.params.attr('limit')){
					self.options.hasNextPage(false);
				}

				self.partition(data);

				can.batch.stop();
			});
		},
		getParams : function(){
			var hubId = can.route.attr('hubId');
			var params = this.options.params.attr();
			var tenant = this.options.state.attr('tenant');

			if(tenant){
				params.tenant_name = tenant;
				params.order = "thread_updated_ts:desc"
			}

			params.hubId = hubId;

			return params;
		},
		updateColumnCount : function(){
			this.options.columnCount(calculateColumnCount(this.element));
		},
		'{window} resize' : function(){
			this.clearTimeout('windowResize');
			this.setTimeout('windowResize', 100, 'updateColumnCount');
		},
		'{columnCount} change' : function(compute, ev, newVal){
			this.columns = makeColumns(newVal);
			this.currentColumn = 0;

			this.partition(this.options.state.attr('bits'));
			this.element.find('.column-wrapper').html(this.columns);
		},
		"{state.bits} partition" : 'partition',
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
			if(!this.options.isLoading() && this.options.hasNextPage()){
				params = this.options.params;
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
		destroy : function(){
			for(var k in this.__timeouts){
				this.clearTimeout(k);
			}
			return this._super.apply(this, arguments);
		}
	});
})