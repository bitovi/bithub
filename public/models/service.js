steal(
'can/model',
'lodash/objects/keys.js',
'can/list/promise',
'can/map/define',
function(Model, _keys){
	var TYPES = {
		disqus : {
			forum : 'Forum'
		},
		facebook : {
			page : 'Page'
		},
		foursquare : {
			venue : 'Venue'
		},
		github : {
			org : 'Organization',
			repo : 'Repo'
		},
		instagram : {
			tag : 'Tag',
			user : 'User'
		},
		meetup : {
			group : 'Group'
		},
		rss : {
			site : 'Site'
		},
		stackexchange : {
			tags : 'Tags'
		},
		tumblr : {
			blog : 'Blog',
			tags : 'Tags'
		},
		twitter : {
			followers : 'Followers',
			hashtag : 'Hashtag',
			search : 'Search',
			timeline : 'Timeline'
		}
	};

	var FEEDS = {
		disqus        : 'Disqus',
		facebook      : 'Facebook',
		foursquare    : 'Foursquare',
		github        : 'GitHub',
		instagram     : 'Instagram',
		meetup        : 'Meetup',
		rss           : 'RSS',
		stackexchange : 'StackExchange',
		tumblr        : 'Tumblr',
		twitter       : 'Twitter'
	};

	return Model.extend({
		resource : '/api/v3/services',
		feeds : FEEDS
	}, {
		define : {
			feed_name : {
				set : function(val){
					var keys = _keys(TYPES[val]);

					this.attr('type_name', keys.length === 1 ? keys[0] : "");

					return val;
				}
			}
		},
		typesForFeed : function(){
			var currentFeed = this.attr('feed_name'),
				types = TYPES[currentFeed];

			return types;
		},
		hasMultipleTypes : function(){
			var typesForFeed = this.typesForFeed();
			return _keys(typesForFeed || {}).length > 1;
		}
	});
})