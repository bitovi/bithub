import can from "can/";
import _keys from "lodash-amd/modern/object/keys";

import 'can/list/promise/';
import 'can/map/define/';
import 'can/construct/super/';

var RELOAD_TIMEOUTS = {};

var isCelluloidError = function(klass){
	return (/celluloid/).test(klass.toLowerCase());
};

var isConfigError = function(klass){
	return (/configerror/).test(klass.toLowerCase());
};

var getErrorMessage = (function(){
	var MESSAGES = {
		autherror: "We are unable to authorize with your service credentials. Are you sure you have rights to access this content?",
		remoteerror: "Service is currently unavailable. We will try to load data again later.",
		unknownerror: "We are so sorry. Unknown error occured when we tried to load data from this service. We have been notified about this error, and we'll try to fix it as soon as possible.",
		ratelimiterror: "Due to number of services authorized with the same account we are unable to load data from this service at the moment. We will try again soon."
	};
	return function(error){
		var klass = error.klass.toLowerCase();
		return MESSAGES[klass] || error.message;
	};
})();


var convertHexToRgb = function(hex){
	var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
	var r, g, b;
	if(result){
		r = parseInt(result[1], 16);
		g = parseInt(result[2], 16);
		b = parseInt(result[3], 16);
		var res = 'rgb(' + r + ',' + g + ',' + b + ')';
		return res;
	}
	return 'rgb(0,0,0)';
};

var GRAPH_COLORS = {
	disqus : convertHexToRgb('#ffe842'),
	facebook : convertHexToRgb('#80a2bd'),
	foursquare : convertHexToRgb('#655557'),
	github : convertHexToRgb('#191749'),
	instagram : convertHexToRgb('#450d0b'),
	meetup : convertHexToRgb('#062233'),
	rss : convertHexToRgb('#183a37'),
	stackexchange : convertHexToRgb('#95b26e'),
	tumblr : convertHexToRgb('#c44900'),
	twitter : convertHexToRgb('#432534'),
	youtube : convertHexToRgb('#432834')
};


var TYPES = {
	disqus : {
		forum : 'Forum'
	},
	facebook : {
		page : 'Page',
		public_page : 'Public Page'
	},
	foursquare : {
		venue : 'Venue'
	},
	github : {
		org : 'Organization',
		repo : 'Repository'
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
		site : 'URL'
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
		term : 'Search',
		user_timeline : 'User Timeline',
		user_retweets: 'User Retweets',
		favorites: 'User Favorites'
	},
	youtube : {
		channel : "Channel",
		playlist: "Playlist"/*,
		user : "User"*/
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
	twitter       : 'Twitter',
	youtube       : 'YouTube'
};

var NEEDS_OAUTH = {
	github : {
		types : ['repo', 'org']
	},
	twitter : {
		types : ['followers', 'hashtag', 'user_timeline', 'term', 'favorites', 'user_retweets']
	},
	meetup : {
		types : ['group']
	},
	facebook : {
		types : ['page']
	},
	foursquare : {
		types : ['venue']
	},
	disqus : {
		types: ['forum']
	},
	instagram : {
		types: ['tag', 'user']
	},
	youtube : {
		types: ['channel', 'playlist', 'user']
	}
};

var formatKey = function(key){
	if(key === 'url'){
		return 'URL';
	}
	return can.capitalize(key.replace(/_/g, ' '));
};

var formatConfig = function(config){
	var res = ['<ul class="config">'];
	for(var k in config){
		res.push('<li><b>' + formatKey(k) + '</b>: ');
		if(can.isPlainObject(config[k])){
			res.push(formatConfig(config[k]));
		} else {
			res.push(config[k]);
		}
		res.push('</li>');
	}
	res.push('</ul>');
	return res.join('');
};

var emptyConfigForService = function(feed){
	var config = {};

	if(feed === 'github'){
		config.tracking = {};
	}

	if(feed === 'stackexchange'){
		config.tags = [];
	}
	return config;
};

var Service = can.Model.extend({
	resource : '/api/v3/services',
	feeds : FEEDS,
	needsOAuth : NEEDS_OAUTH,
	createEmptyService : function(feed){

		return new this({
			feed_name : feed,
			config: emptyConfigForService(feed)
		});
	},
	errored : function(service){
		can.trigger(this, 'errored', [this]);
	},
	messageFromLiveService : function( msg ) {
		var cb = can.noop,
			timeout = 1,
			self = this,
			timeoutKey;

		if(typeof msg === 'string'){
			msg = JSON.parse(msg);
		}

		timeoutKey = msg.service.id;

		if(msg.service.empty_results){
			timeoutKey = msg.service.id + '-noResults';
			cb = function(service){
				if(service.attr('entity_count') === 0){
					service.hasNoResults();
				}
			};
			timeout = 2000;
		}

		clearTimeout(RELOAD_TIMEOUTS[timeoutKey]);

		RELOAD_TIMEOUTS[timeoutKey] = setTimeout(function(){
			self.findOne({id: msg.service.id}).then(cb);
		}, timeout);
	}
}, {
	define : {
		feed_name : {
			set : function(val){
				var keys = _keys(TYPES[val]);

				this.attr('type_name', keys.length === 1 ? keys[0] : "");
				this.attr('graphColor', GRAPH_COLORS[val]);

				return val;
			}
		},
		type_name : {
			set : function(val){
				this.attr('config', emptyConfigForService(this.attr('feed_name')));
				return val;
			}
		},
		error : {
			set : function(val){
				var klass = val && val.klass;
				if(klass && isCelluloidError(klass)){
					return;
				}
				return val;
			}
		},
		approved_by_default : {
			set : function(val){
				return !!val;
			}
		}
	},
	serialize : function(){
		var data = this._super.apply(this, arguments);

		if(!(data.feed_name === 'instagram' && data.type_name === 'user') && !(data.feed_name === 'facebook' && data.type_name === 'public_page')){
			if(data.config){
				delete data.config.display_name;
			}
		}

		return {
			service : data
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
		var output = [],
			config = this.attr('config');

		config = config ? config.attr() : config;

		if(!config){
			return;
		}

		for( var key in config ) {
			output.push(key + ': ' + config[key]);
		}

		// remove last ', '
		return output.join('<br>');
	},
	hasNoResults : function(){
		can.batch.start();
		if(this.attr('_isNewlyCreated')){
			this.attr('noResults', true);
		}
		this.attr({
			error: null
		});
		can.batch.stop();
	},
	clearNoResults : function(){
		this.removeAttr('noResults');
	},
	save : function(){
		this.removeAttr('noResults');
		can.trigger(this.constructor, 'saving', [this]);
		return this._super.apply(this, arguments);
	},
	formattedConfig : function(){
		return formatConfig(this.attr('config').attr());
	},
	formattedError : function(){
		return getErrorMessage(this.attr('error'));
	},
	formattedErrorClass : function(){
		var klass = this.attr('error.klass');
		return !isConfigError(klass) ? '' : 'Configuration Error';
	},
	clearErrors : function(){
		this.removeAttr('error');
	},
	isLoading : function(){
		return this.attr('state') === 'loading';
	}
});

Service.on('created', function(ev, service){
	service.attr('_isNewlyCreated', true);
});

Service.on('updated', function(ev, service){
	service.attr('_isNewlyCreated', true);
});

export default Service;
