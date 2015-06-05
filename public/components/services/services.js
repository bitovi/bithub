import can from "can/";
import Models from "models/";
import initView from "./services.stache!";

import "./services.less!";
import "components/service-form/";
import "components/services-list/";

can.Component.extend({
	tag : 'bh-services',
	template : initView,
	scope : {
		currentService : null,
		define : {
			services : {
				get : function() {
					return new Models.Service.List({
						embed_id: this.attr('state.hubId')
					});
				}
			}
		},
		feeds : Models.Service.feeds,
		toggleNewService : function(ctx, el){
			var feed = el.data('feed');
			var currentService = this.attr('currentService');
			var check = currentService && currentService.isNew() && currentService.attr('feed_name') === feed;

			if(check){
				this.attr('currentService', null);
				return;
			}

			this.attr('currentService', Models.Service.createEmptyService(feed));
		}
	},
	events : {
		init : function(){
			this.preloadIcons();
		},
		preloadIcons : function(){
			var feeds = this.scope.feeds.attr();
			var img;
			for(var k in feeds){
				img = new Image();
				img.src = "/images/social-empty/" + k + '.png';
			}
		}
	},
	helpers : {
		currentServiceIsNewAndHasFeedName : function(feedName, opts){
			var currentService = this.attr('currentService');

			feedName = can.isFunction(feedName) ? feedName() : feedName;

			if(!currentService){
				return opts.inverse(this);
			}

			if(currentService.isNew() &&
				 currentService.attr('feed_name') === feedName){
				return opts.fn(this);
			}
			return opts.inverse(this);
		}
	}
});
