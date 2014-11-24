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
		disqus : 'plug',
	}

	return Component.extend({
		tag : 'bh-services',
		template : initView,
		scope : {
			currentService : null,
			feeds : Models.Service.feeds,
			toggleNewService : function(ctx, el){
				var feed = el.data('feed'),
					currentService = this.attr('currentService');

				if(currentService && currentService.isNew() && currentService.attr('feed_name') === feed){
					this.attr('currentService', null);
					return;
				}

				this.attr('currentService', new Models.Service({
					feed_name : feed
				}));
			},
			currentServiceFeedName : function(){
				var feed = this.attr('currentService').attr('feed_name');
				return Models.Service.feeds[feed];
			}
		},
		events : {
			'.scroll-left mouseenter' : function(){
				this.__scrollDirection = 'left';
				this.scrollPicker();
			},
			'.scroll-right mouseenter' : function(){
				this.__scrollDirection = 'right';
				this.scrollPicker();
			},
			scrollPicker : function(){
				var servicesEl = this.element.find('.new-service-picker'),
					self = this,
					marginLeft = parseInt(servicesEl.css('margin-left'), 10),
					containerWidth = this.element.find('.service-slider-wrap').innerWidth() - 1,
					width = servicesEl.outerWidth() - 2;

				if(this.__scrollDirection === 'left' && marginLeft < 0){
					this.__scrollTimeout = setTimeout(function(){
						servicesEl.css('margin-left', marginLeft + 2);
						self.scrollPicker();
					}, 4);
				}

				if(this.__scrollDirection === 'right' && Math.abs(marginLeft) + containerWidth < width){
					this.__scrollTimeout = setTimeout(function(){
						servicesEl.css('margin-left', marginLeft - 2);
						self.scrollPicker();
					}, 4);
				}
			},
			'.scroll-left, .scroll-right mouseleave' : function(){
				clearTimeout(this.__scrollTimeout);
				delete this.__scrollDirection;
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