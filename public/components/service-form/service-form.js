steal(
'can/component',
'./service-form.stache!',
'models',
'./service-form.less!',
'can/map/define',
'components/service-forms/disqus-forum',
'components/service-forms/facebook-page',
'components/service-forms/foursquare-venue',
'components/service-forms/github-org',
'components/service-forms/github-repo',
'components/service-forms/instagram-tag',
'components/service-forms/instagram-user',
'components/service-forms/meetup-group',
'components/service-forms/rss-site',
'components/service-forms/stackexchange-tags',
'components/service-forms/tumblr-blog',
'components/service-forms/tumblr-tag',
'components/service-forms/twitter-followers',
'components/service-forms/twitter-hashtag',
'components/service-forms/twitter-user_timeline',
function(Component, initView, Models){

	var makeTemplate = function(feed, type){
		var componentName = ['bh', feed, type, 'service'].join('-');
		return can.stache("<" + componentName + " map='{service}'></" + componentName + '>');
	};

	return Component.extend({
		tag : 'bh-service-form',
		template: initView,
		scope : {
			saveService : function(service, el, ev){
				ev.preventDefault();

				this.attr('service').attr('embed_id', this.state.attr('hubId'));

				this.attr('service').save( function( model ) {
					console.log( 'SAVED' );
					console.log( arguments );
				}, function( error ) {
					console.log( 'ERROR' );
					console.log( arguments );
				});

				this.attr('service', null);
			}
		},
		helpers : {
			renderForm : function(opts){
				var service = this.attr('service'),
					feed = service.attr('feed_name'),
					type = service.attr('type_name');

				if(type && feed){
					return makeTemplate(feed, type)(opts.scope.add({service: this.attr('service')}));
				}
			}
		}
	});
});
