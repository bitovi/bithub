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
'components/helpers.js',
function(Component, initView, Models){

	var makeTemplate = function(feed, type){
		var componentName = ['bh', feed, type.replace(/_/g, '-'), 'service'].join('-'),
			template = '<' + componentName + ' map="{service}" errors="{errors.config}"></' + componentName + '>{{{saveButtons}}}',
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
			isHidden: false,
			missingConfig : false,
			errors: null,
			define : {
				service : {
					set : function(val){
						this.clearErrors();
						return val;
					}
				}
			},
			init : function(){
				console.log(this.attr())
			},
			saveService : function(formData, el, ev){
				ev.preventDefault();

				var self = this,
					service = this.attr('service'),
					services = this.attr('services'),
					serviceCompute = this.compute('service');

				service.attr('embed_id', this.state.attr('hubId'));
				services.unshift( service );

				service.save( function( newService ) {

				}, function( error ) {
					var index = services.indexOf(service);
					var attrs = {
						isHidden: false
					};
					var errors;

					services.splice(index, 1);

					if(error.status === 400){
						attrs.missingConfig = true;
					} else if(error.status = 406){
						try {
							errors = JSON.parse(error.responseText).errors.config_attrs;
						} catch(e){
							errors = {};
						}
						attrs.errors = errors;
					}

					Models.Service.errored(service);

					self.attr(attrs);
				});

				this.attr({
					isHidden: true,
					missingConfig: false,
					errors: null
				});
			},
			clearService : function(){
				can.batch.start();
				this.attr('service', null);
				this.clearErrors();
				can.batch.stop();
			},
			clearErrors : function(){
				this.attr({
					errors: null,
					missingConfig: false
				});
			},
			currentServiceFeedName : function(){
				var feed = this.attr('service').attr('feed_name');
				return Models.Service.feeds[feed];
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
