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
			// location : 'Location',
			// geography : 'Geography',
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
			tag : 'Tag'
		},
		twitter : {
			followers : 'Followers',
			hashtag : 'Hashtag',
			user_timeline : 'User Timeline'
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
		serialize : function(){
			return {
				service : this._super.apply(this, arguments)
			};
		},
		typesForFeed : function(){
			var currentFeed = this.attr('feed_name'),
				types = TYPES[currentFeed];

			return types;
		},
		hasMultipleTypes : function(){
			var typesForFeed = this.typesForFeed();
			return _keys(typesForFeed || {}).length > 1;
		},
		printFeed : function() {
			return FEEDS[ this.attr('feed_name') ];
		},
		printType : function() {
			return TYPES[ this.attr('feed_name') ][ this.attr('type_name') ];
		},
		printConfig: function() {
			var output = '',
				config = this.attr('config').attr();

			for( var key in config ) {
					output += key + ': ' + config[key] + ', ';
			}

			// remove last ', '
			return output.substring(0, output.length -2);
		}
	});
});
