import can from "can";
import initView from "./service-config-formatter.stache!";
import "./service-config-formatter.less!";

can.Component.extend({
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
		cutoff : function(){
			var str, opts;
			if(arguments.length === 1){
				opts = arguments[0];
				str = opts.fn();
			} else {
				str = arguments[0];
				opts = arguments[1];
			}

			str = can.isFunction(str) ? str() : str;

			if(str.length > 50){
				str = str.substr(0, 50) + '&hellip;';
			}

			return str;
		}
	}
});
