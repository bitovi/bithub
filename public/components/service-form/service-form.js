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
'components/service-forms/twitter-term',
'components/service-forms/twitter-user-timeline',
'components/oauthorizer',
function(Component, initView, Models){

	var makeTemplate = function(feed, type){
		var componentName = ['bh', feed, type.replace(/_/g, '-'), 'service'].join('-'),
			template = '<' + componentName + ' map="{service}"></' + componentName + '>{{{saveButtons}}}',
			needsOAuth = Models.Service.needsOAuth[feed];

		needsOAuth = needsOAuth && can.inArray(type, needsOAuth.types) > -1;


		if(needsOAuth){
			template = [
				'<bh-oauthorizer feed="' + feed + '">',
				template,
				'</bh-oauthorizer>'
			].join('');
		}

		return can.stache(template);
	};

	return Component.extend({
		tag : 'bh-service-form',
		template: initView,
		scope : {
			init : function(){
				console.log(this.attr())
			},
			saveService : function(formData, el, ev){
				ev.preventDefault();

				var self = this,
					service = this.attr('service'),
					services = this.attr('services');

				service.attr('embed_id', this.state.attr('hubId'));
				services.push( service );

				service.save( function( newService ) {
					console.log('Service saved!');
				}, function( error ) {
					var index = services.indexOf(service);
					services.splice(index, 1);
					console.log('Error on creating service: ', error );
				});

				this.attr('service', null);
			},
			clearService : function(){
				this.attr('service', null);
			}
		},
		helpers : {
			renderForm : function(opts){
				var service = this.attr('service'),
					feed = service.attr('feed_name'),
					type = service.attr('type_name');

				if(type && feed){
					return makeTemplate(feed, type)(opts.scope, {
						saveButtons : function(){
							return opts.fn()
						}
					});
				}
			}
		}
	});
});
