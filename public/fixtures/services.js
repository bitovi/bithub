steal('can/util/fixture', function(fixture){
	
	var config = [{
		feed_name: "twitter",
		type_name: "user_timeline",
		config: { handle: "canjs" }
	},{
		feed_name: "twitter",
		type_name: "followers",
		config: { handle: "bitovi" }
	},{
		feed_name: "twitter",
		type_name: "search",
		config: { term: "canjs is best" }
	},{
		feed_name: "disqus",
		type_name: "forum",
		config: { url: "pltconfusion.com" }
	},{
		feed_name: "facebook",
		type_name: "page",
		config: { id: "24356776342"}
	},{
		feed_name: "foursquare",
		type_name: "venue",
		config: { id: "283jehren"}
	},{
		feed_name: "instagram",
		type_name: "user",
		config: { id: "id"}
	},{
		feed_name: "foursquare",
		type_name: "tag",
		config: { tag: "blago"}
	},{
		feed_name: "meetup",
		type_name: "group",
		config: { id: "id"}
	},{
		feed_name: "github",
		type_name: "repo",
		config: {
			name: "retro/apitizer",
			tracking: {
				activity: true,
				issues: true,
				pull_req: false,
				code: true
			}
		}
	},{
		feed_name: "github",
		type_name: "org",
		config: { name: "bitovi" }
	},{
		feed_name: "stackexchange",
		type_name: "tags",
		config: { tags: ["canjs", "jquerypp", "javascriptmvc"] }
	},{
		feed_name: "tumblr",
		type_name: "blog",
		config: { hostname: 'peacecorps.tumblr.com'}
	},{
		feed_name: "tumblr",
		type_name: "tags",
		config: { tags: ["braclets", "diy", "gosling"] }
	},{
		feed_name: "rss",
		type_name: "site",
		config: { url: "pltconfusion.com/feed" }
	}];

	var serviceStore = can.fixture.store(config.length, function(i){
		return can.extend({
			id : i + 1,
		}, config[i]);
	});

	can.fixture('GET /api/v3/services', serviceStore.findAll);
	can.fixture('GET /api/v3/services/{id}', serviceStore.findOne);
	can.fixture('POST /api/v3/services', serviceStore.create);
	can.fixture('PUT /api/v3/services/{id}', serviceStore.update);
	can.fixture('DELETE /api/v3/services/{id}', serviceStore.destroy);

});