steal(
'can/component',
'./bits.stache!',
'models',
'lodash/collections/map.js',
'lodash/collections/reduce.js',
'./bits.less!',
'can/map/define',
'components/service-loader',
'bit',
'can/construct/proxy',
function(Component, initView, Models, _map, _reduce){

	var CARD_MIN_WIDTH = 300;
	var CARD_TEMPLATE = can.stache('<bh-bit bit="{this}"></bh-bit>');

	var calculateColumnCount = function(el){
		if(el.width < CARD_MIN_WIDTH) {
			return 1;
		}
		return Math.min(5, Math.floor(el.width() / CARD_MIN_WIDTH));
	}

	return Component.extend({
		tag : 'bh-bits',
		template : initView,
		scope : {
			define : {
				columnCount : {
					set : function(val){
						if(parseInt(this.attr('columnCount'), 10) !== parseInt(val, 10)){
							this.makePartitioner(val);
							this.partition(val);
						}
						return val;
					}
				}
			},
			columns: [],
			loading : false,
			hasNextPage : true,
			init : function(){
				var self = this;

				this.attr({
					params: {
						offset: 0,
						limit: 15,
						order: "created_at:desc"
					}
				});

				this.loadData();
			},
			getParams : function(){
				var hubId = can.route.attr('hubId');
				var params = this.attr('params').attr();
				var tenant = this.attr('state.tenant');

				if(tenant){
					params.tenant_name = tenant;
					params.order = "thread_updated_ts:desc"
				}

				params.hubId = hubId;

				return params;
			},
			loadData : function(){
				var self = this;

				this.attr('loading', true);

				Models.Bit.findAll(this.getParams()).then(function(data){
					var bits = self.attr('bits');

					can.batch.start();

					bits.push.apply(bits, data);
					self.attr('loading', false);

					if(data.length < self.attr('params.limit')){
						self.attr('hasNextPage', false);
					}

					self.partitionAppendedData(data);

					can.batch.stop();
				});
			},
			partition : function(columnCount){
				var bits = this.attr('bits');
				var bitsLength = bits.attr('length');
				var partitioner;

				this.attr('columns').replace(
					_map(new Array(columnCount || this.attr('columnCount')), function(){
						return [];
					})
				);

				for(var i = 0; i < bitsLength; i++){
					this.partitioner.add(bits[i])
				}
			},
			makePartitioner : function(columnCount){
				var currentColumn = 0;
				var self = this;

				this.partitioner = {
					add : function(bit){
						self.attr('columns.' + currentColumn).push(bit);
						currentColumn++;
						if(currentColumn === columnCount){
							currentColumn = 0;
						}
					},
					currentColumn : function(){
						return currentColumn;
					}
				}
			},
			partitionAppendedData : function(bits){
				var bitsLength = bits.attr('length');

				for(var i = 0; i < bitsLength; i++){
					this.partitioner.add(bits[i]);
				}
			},
			nextPage : function(){
				var params;
				if(!this.attr('loading') && this.attr('hasNextPage')){
					params = this.attr('params');
					params.attr('offset', this.attr('bits.length'));
					this.loadData();
				}
			}
		},
		helpers : {
			renderCard : function(bit){
				bit = can.isFunction(bit) ? bit() : bit;

				this.__cardCache = this.__cardCache || {};

				if(!this.__cardCache[bit.id]){
					this.__cardCache[bit.id] = CARD_TEMPLATE(bit).firstChild;
				}

				return this.__cardCache[bit.id];
			}
		},
		events : {
			inserted : function(){
				this.$document = $(document);
				this.$window = $(window);
				this.$body = $('body');
				this.calculateColumnCount();
				this.loadingCount = 0;
			},
			calculateColumnCount : function(){
				this.scope.attr('columnCount', calculateColumnCount(this.element));
			},
			"{window} resize" : function(){
				clearTimeout(this.__resizeTimeout);
				this.__resizeTimeout = setTimeout(this.proxy('calculateColumnCount'), 100);
			},
			scroll : 'appendContent',
			"{scope.bits} partition" : function(){
				this.scope.partition();
			},
			"{scope.bits} remove" : function(bits, ev, oldVals, where){
				var ids = _map(oldVals, function(bit){
					return bit.id;
				});

				for(var i = 0; i < ids.length; i++){
					delete this.scope.__cardCache[ids[i]];
				}

				this.scope.partition();
			},
			'bh-bit loading' : function(){
				this.loadingCount++;
			},
			'bh-bit loaded' : function(){
				this.loadingCount--;
			},
			appendContent : function(){
				var self = this;
				clearTimeout(this.__appendContentTimeout);
				this.__appendContentTimeout = setTimeout(function(){
					var scrollTop = self.element.scrollTop();
					var scrollHeight = self.element.prop('scrollHeight');
					var height = self.element.height();
					(scrollHeight - scrollTop - height < 500) && self.loadingCount <= 0 && self.scope.nextPage();
				}, 100);
			},
		}
	})
});