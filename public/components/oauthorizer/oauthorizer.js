steal(
'can/component',
'./oauthorizer.stache!',
'models',
'./oauthorizer.less!',
'can/map/define',
function(Component, initView, Models){


	var OAuthConnect = function(feed) {
		var windowPropsStr     = "width=800,height=600,scrollbars=yes",
			title              = "OAuth Login",
			host               = window.location.host.split('.'),
			url                = '/auth/' + feed,
			oauthWindow        = window.open(url, title, windowPropsStr),
			def                = can.Deferred(),
			oauthWindowSweeper = window.setInterval(function() {
				if (oauthWindow.closed) {
					clearInterval(oauthWindowSweeper);
					def.resolve();
				}
			}, 100);
		return def;
	}


	var BUTTON_LABELS = {
		facebook   : '<i class="fa fa-facebook-square"></i> Log in with Facebook',
		twitter    : 'Sign in with Twitter',
		github     : 'Log in in with GitHub',
		meetup     : 'Log in with Meetup',
		foursquare : 'Log in with Foursquare',
		instagram  : 'Log in with Instagram',
		disqus     : 'Log in with Disqus'
	}

	var compareIdentities = function(a, b){
		if(a.created_at_timestamp > b.created_at_timestamp) return -1;
		if(a.created_at_timestamp < b.created_at_timestamp) return 1;
		return 0;
	}

	return Component.extend({
		tag : 'bh-oauthorizer',
		template : initView,
		scope : {
			selectedService : null,
			init : function(){
				var self = this;
				Models.Identity.findAll({}).then(function(identities){
					self.attr('identities', identities);
				});
			},
			isAuthorized : function(){
				return this.hasIdentityForService(this.attr('feed'));
			},
			identitiesForCurrentService : function(){
				var currentService = this.attr('feed');
				return can.grep(this.attr('identities'), function(identity){
					return identity.attr('provider') === currentService;
				});
			},
			hasIdentityForService : function(service){
				var identities = this.attr('identities'),
					length = identities.attr('length');

				for(var i = 0; i < length; i++){
					if(identities.attr(i + '.provider') === service){
						return true;
					}
				}
				return false;
			},
			buttonLabel : function(){
				return BUTTON_LABELS[this.attr('feed')] || 'Authorize Service';
			},
			identities: null,
			isAuthorizing : false,
			isAuthorizingOrHasIdentity : function(){
				var hasIdentity = !!this.attr('service.brand_identity_id');
				return this.attr('isAuthorizing') || hasIdentity;
			},
			isPending : function(){
				return this.attr('identities') === null;
			},
			oauthorize : function(ctx, el, ev){
				var self = this,
					feed = this.attr('feed');

				ev.preventDefault();

				if(this.attr('service.brand_identity_id')) return;

				if(!feed){
					throw "You must initialize bh-oauthorizer component with the `feed` attribute";
				}

				this.attr('isAuthorizing', true);

				OAuthConnect(feed).then(function(){
					Models.Identity.findAll({}).then(function(identities){
						self.attr({
							identities : identities,
							isAuthorizing : false
						});
					});
				});
			}
		},
		events : {
			"{scope} isAuthorizing" : function(){
				var self = this;
				setTimeout(function(){
					var identities = self.scope.identitiesForCurrentService();
					if(identities.length){
						identities.sort(compareIdentities);
						self.scope.attr('service').attr('brand_identity_id', parseInt(identities[0].id));
						self.element.find('select.service-brand').val(identities[0].id);
					}
				}, 10);
			}
		},
		helpers : {
			ifServiceIs : function(service, opts){
				service = can.isFunction(service) ? service() : service;
				if(service === this.attr('feed')){
					return opts.fn();
				}
			},
			withSelectedService : function(opts){
				var selectedService = this.attr('service').attr('brand_identity_id');
				return selectedService && opts.fn();
			}
		}
	})
});