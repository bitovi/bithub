steal(
'can/model',
'lodash/objects/keys.js',
'can/list/promise',
'can/map/define',
'can/construct/super',
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
			user_timeline : 'User Timeline',
			term : 'Term'
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

	var NEEDS_OAUTH = {
		github : {
			types : ['repo', 'org']
		},
		twitter : {
			types : ['followers', 'hashtag', 'user_timeline', 'term']
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
		}
	};

	var formatKey = function(key){
		if(key === 'url') return 'URL';
		return can.capitalize(key.replace(/_/g, ' '));
	}

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
		res.push('</ul>')
		return res.join('');
	}

	return Model.extend({
		resource : '/api/v3/services',
		feeds : FEEDS,
		needsOAuth : NEEDS_OAUTH,
		createEmptyService : function(feed){
			var config = {};


			if(feed === 'github'){
				config.tracking = {};
			}

			if(feed === 'stackexchange'){
				config.tags = [];
			}

			return new this({
				feed_name : feed,
				config: config
			});
		},
		errored : function(service){
			can.trigger(this, 'errored', [this]);
		}
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
			this.attr('noResults', true);
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
			var klass = this.attr('error.klass');
			if(klass !== 'UnknownError'){
				return this.attr('error.message');
			}
		},
		formattedErrorClass : function(){
			return this.attr('error.klass');
		}
	});
});
