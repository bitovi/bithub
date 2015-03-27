steal('can/model', function(Model){
	return Model.extend({
		findOne: '/api/v3/subscriptions/current'
	}, {
		canAddHub : function(hubs){
			var currentLength = hubs.attr('length');
			var limit = this.attr('plan.limits.embeds_per_brand') || Infinity;
			return currentLength < limit;
		},
		canAddService : function(services, feed, type){
			var currentLength = services.attr('length');
			var limit = this.attr('plan.limits.services_per_embed') || Infinity;
			var currentTypeFeed = [feed, type].join('_');
			var limitCurrentTypeFeed = this.attr('plan.limits').attr(currentTypeFeed) || Infinity;
			var servicesWithCurrentTypeFeed = services.filter(function(s){
				return s.attr('feed_name') === feed && s.attr('type_name') === type;
			}); 

			if(currentLength >= limit){
				return false;
			}
			if(servicesWithCurrentTypeFeed.attr('length') >= limitCurrentTypeFeed){
				return false;
			}
			return true;
		}
	})
})
