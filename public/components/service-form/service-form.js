steal(
'can/component',
'./service-form.stache!',
'models',
'./service-form.less!',
'can/map/define',
'components/service-forms/disqus-forum',
'components/service-forms/facebook-page',
'components/service-forms/facebook-public-page',
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
'components/service-forms/youtube-channel',
'components/service-forms/youtube-playlist',
'components/service-forms/youtube-user',
'components/oauthorizer',
'components/helpers.js',
function(Component, initView, Models){

	var FEED_INFOS = {
		foursquare: 'You must be a venue manager to be able to add a venue.'
	};

	var makeTemplate = function(feed, type){
		var componentName = ['bh', feed, type.replace(/_/g, '-'), 'service'].join('-'),
			template = '<' + componentName + ' map="{service}" errors="{errors.config}"></' + componentName + '>{{{saveButtons}}}',
			needsOAuth = Models.Service.needsOAuth[feed];

		needsOAuth = needsOAuth && can.inArray(type, needsOAuth.types) > -1;


		if(needsOAuth){
			template = [
				'<bh-oauthorizer feed="' + feed + '" service="{service}">',
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
			typeErros: null,
			saveDisabled : false,
			define : {
				service : {
					set : function(val){
						this.clearErrors();
						return val;
					}
				}
			},
			saveService : function(formData, el, ev){
				ev.preventDefault();

				var self = this,
					service = this.attr('service'),
					services = this.attr('services'),
					serviceCompute = this.compute('service');

				service.attr('embed_id', this.state.attr('hubId'));
				if(service.isNew()){
					services.unshift( service );
				}
				

				service.save( function( newService ) {
					self.clearService();
				}, function( error ) {
					var index = services.indexOf(service);
					var attrs = {
						isHidden: false
					};
					var errorsResponse;
					var errors, typeErrors;

					services.splice(index, 1);

					if(error.status === 400){
						attrs.missingConfig = true;
					} else if(error.status = 406){
						try {
							errorsResponse = JSON.parse(error.responseText).errors;
							errors = errorsResponse.config_attrs;
							typeErrors = errorsResponse.type_name;
						} catch(e){
							errors = {};
						}
						attrs.errors = errors;
					}

					if(typeErrors){
						self.attr('typeErrors', typeErrors);
					}

					Models.Service.errored(service);

					self.attr(attrs);
				});

				this.attr({
					isHidden: service.isNew(),
					missingConfig: false,
					errors: null
				});
			},
			feedInfo : function(){
				return FEED_INFOS[this.attr('service.feed_name')];
			},
			clearService : function(){
				can.batch.start();
				this.attr({
					saveDisabled: false,
					service: null
				});
				this.clearErrors();
				can.batch.stop();
			},
			clearErrors : function(){
				this.attr({
					errors: null,
					typeErrors: null,
					missingConfig: false
				});
			},
			currentServiceFeedName : function(){
				var service = this.attr('service');
				if(!service) { 
					return
				}
				var feed = service.attr('feed_name');
				return Models.Service.feeds[feed];
			}
		},
		events : {
			"service:saveDisabled" : function(){
				var self = this;
				setTimeout(function(){
					self.element && self.element.find('button.save-service').prop('disabled', true);
				}, 1);
				
			},
			"service:saveEnabled" : function(){
				var self = this;
				setTimeout(function(){
					self.element && self.element.find('button.save-service').prop('disabled', false);
				}, 1);
			}
		},
		helpers : {
			renderForm : function(opts){
				var service = this.attr('service'), feed, type;
				
				if(!service){ 
					return;
				}

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
