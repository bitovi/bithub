steal(
'can/component',
'./service-config-formatter.stache!',
'./service-config-formatter.less!',
function(Component, initView){
	return Component.extend({
		template : initView,
		tag: 'bh-service-config-formatter',
		scope : {
			lowercasedFeedName : function(){
				return this.attr('service.feed_name').toLowerCase();
			},
			lowercasedTypeName : function(){
				return this.attr('service.type_name').toLowerCase();
			}
		},
		helpers : {
			isFeedAndType : function(feed, type, opts){
				feed = (can.isFunction(feed) ? feed() : feed).toLowerCase();
				type = (can.isFunction(type) ? type() : type).toLowerCase();
				if(feed === this.lowercasedFeedName() && type === this.lowercasedTypeName()){
					return opts.fn();
				}
			},
			joined : function(arr, opts){
				arr = can.isFunction(arr) ? arr() : arr;
				return arr.join(', ');
			},
			subdomain : function(url){
				url = can.isFunction(url) ? url() : url;
				return url.split('.').shift();
			}
		}
	})
})