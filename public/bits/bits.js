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

	var CARD_MIN_WIDTH = 350;
	var bitTemplate = can.stache('<bh-bit bit="{this}"></bh-bit>');

	var calculateColumnCount = function(el){
		return Math.min(4, Math.floor(el.width() / CARD_MIN_WIDTH));
	}

	return Component.extend({
		tag : 'bh-bits',
		template : initView,
		scope : {
			loading : false,
			hasNextPage : true,
			init : function(){
				var self = this;

				this.attr({
					params: {
						offset: 0,
						limit: 50,
						order: "created_at:desc"
					}
				});

				this.loadData();
			},
			getParams : function(){
				var hubId = can.route.attr('hubId');
				var params = this.attr('params').attr();

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

					can.batch.stop();
				});
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
		events : {
			inserted : function(){
				this.element.on('scroll', this.proxy('appendContent'));
				this.__bitsCache = {};
				this.__columns = [];
				this.__currentlyRendered = {};
				this.__firstRender = false;
				this.renderContent();
			},
			"{window} resize" : function(){
				clearTimeout(this.__resizeTimeout);
				this.__resizeTimeout = setTimeout(this.proxy('renderContent'), 300);
			},
			"{state.bits} length" : function(){
				clearTimeout(this.__addedTimeout);
				this.__addedTimeout = setTimeout(this.proxy('renderContent'), 4);
			},
			renderContent : function(){
				var bits = this.scope.attr('bits');
				var columnCount = calculateColumnCount(this.element);
				var columns = this.getColumns(columnCount);
				var bigFragment = document.createDocumentFragment();
				var currentColumn = 0;

				for(var i = 0; i < bits.length; i++){
					currentBit = bits[i];
					if(!this.__bitsCache[currentBit.id]){
						this.__bitsCache[currentBit.id] = bitTemplate(currentBit).firstChild;
					}
					if(this.__currentlyRendered[currentBit.id] !== currentColumn){
						columns[currentColumn].appendChild(this.__bitsCache[currentBit.id]);
						this.__currentlyRendered[currentColumn.id] = currentColumn;
						currentColumn++;
						if(currentColumn === columnCount){
							currentColumn = 0;
						}
					}
				}

				_reduce(columns, function(bFrag, child){
					bFrag.appendChild(child);
					return bFrag;
				}, bigFragment);

				this.element.removeClass('columns-1 columns-2 columns-3 columns-4');
				this.element.addClass('columns-' + columnCount);
				this.element.find('.column-wrapper').html(bigFragment);
			},
			getColumns : function(columnCount){
				var columns;
				if(this.__columns.length === columnCount){
					columns = this.__columns;
				} else {
					columns = _map(new Array(columnCount), function(){
						var div = document.createElement('div');
						div.className = 'column';
						return div;
					});
				}
				this.__columns = columns;
				return this.__columns;
			},
			appendContent : function(){
				var self = this;
				clearTimeout(this.__appendContentTimeout);
				this.__appendContentTimeout = setTimeout(function(){
					var scrollTop = self.element.scrollTop();
					var scrollHeight = self.element.prop('scrollHeight');
					var height = self.element.height();

					(scrollHeight - scrollTop - height < 500) && self.scope.nextPage();
				}, 100);
			},
			removed : function(){
				this.element.off('scroll');
			}
		}
	})
});