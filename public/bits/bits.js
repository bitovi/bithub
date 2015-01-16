steal(
'can/component',
'./bits.stache!',
'models',
'./bits.less!',
'can/map/define',
'components/service-loader',
'bit',
'can/construct/proxy',
function(Component, initView, Models){
	return Component.extend({
		tag : 'bh-bits',
		template : initView,
		scope : {
			loading : false,
			hasNextPage : true,
			init : function(){
				var self = this;

				this.attr('params', {
					offset: 0,
					limit: 50
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
					params.attr('offset', params.attr('offset') + params.attr('limit'));
					this.loadData();
				}
			}
		},
		events : {
			inserted : function(){
				this.element.on('scroll', this.proxy('appendContent'));
			},
			appendContent : function(){
				var self = this;
				clearTimeout(this.__appendContentTimeout);
				this.__appendContentTimeout = setTimeout(function(){
					var scrollTop = self.element.scrollTop();
					var scrollHeight = self.element.prop('scrollHeight');
					var height = self.element.height();

					(scrollHeight - scrollTop - height < 300) && self.scope.nextPage();
				}, 100);
			},
			removed : function(){
				this.element.off('scroll');
			}
		}
	})
});