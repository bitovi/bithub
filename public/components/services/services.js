steal(
'can/component',
'models',
'./services.stache!',
'./services.less!',
'components/service-form',
'components/services-list',
function(Component, Models, initView){

	var ICON_MAPPINGS = {
		stackexchange : 'stack-exchange',
		meetup : 'plug',
		disqus : 'plug'
	};

	return Component.extend({
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
				var feed = el.data('feed'),
					currentService = this.attr('currentService');

				if(currentService && currentService.isNew() && currentService.attr('feed_name') === feed){
					this.attr('currentService', null);
					return;
				}

				this.attr('currentService', Models.Service.createEmptyService(feed));
			}
		},
		helpers : {
			currentServiceIsNewAndHasFeedName : function(feedName, opts){
				var currentService = this.attr('currentService');

				feedName = can.isFunction(feedName) ? feedName() : feedName;

				if(!currentService) return;

				if(currentService.isNew() && currentService.attr('feed_name') === feedName){
					return opts.fn(this);
				}
			},
			iconFeedMapping : function(feed){
				feed = can.isFunction(feed) ? feed() : feed;

				return ICON_MAPPINGS[feed] || feed;
			}
		}
	})
})
