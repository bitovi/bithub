import can from "can";
import initView from "./oauthorizer.stache!";
import Models from "models/";

import "./oauthorizer.less!";
import "can/map/define/";

var getIdentityProvider = function(feed){
	if(feed === 'youtube'){
		return 'google_oauth2';
	}
	return feed;
};

var OAuthURL = function(feed){
	return '/auth/' + getIdentityProvider(feed);
};

var OAuthConnect = function(feed) {
	var windowPropsStr     = "width=800,height=600,scrollbars=yes",
			title              = "OAuth Login",
			url                = OAuthURL(feed),
			oauthWindow        = window.open(url, title, windowPropsStr),
			def                = can.Deferred(),
			oauthWindowSweeper = window.setInterval(function() {
				if (oauthWindow.closed) {
					clearInterval(oauthWindowSweeper);
					def.resolve();
				}
			}, 100);
	return def;
};


var BUTTON_LABELS = {
	facebook   : '<i class="fa fa-facebook-square"></i> Log in with Facebook',
	twitter    : 'Sign in with Twitter',
	github     : 'Log in in with GitHub',
	meetup     : 'Log in with Meetup',
	foursquare : 'Log in with Foursquare',
	instagram  : 'Log in with Instagram',
	disqus     : 'Log in with Disqus'
};

var SERVICE_LABELS = {
	facebook   : 'Facebook',
	twitter    : 'Twitter',
	github     : 'GitHub',
	meetup     : 'Meetup',
	foursquare : 'Foursquare',
	instagram  : 'Instagram',
	disqus     : 'Disqus',
};

var compareIdentities = function(a, b){
	if(a.created_at_timestamp > b.created_at_timestamp){
		return -1;
	}
	if(a.created_at_timestamp < b.created_at_timestamp){
		return 1;
	}
	return 0;
};

can.Component.extend({
	tag : 'bh-oauthorizer',
	template : initView,
	scope : {
		define : {
			accountType : {
				set : function(val){
					if(val === 'new'){
						this.attr('service').attr('brand_identity_id', null);
					} else if(this.attr('identities')) {
						this.selectFirstIdentity();
					}
					return val;
				}
			}
		},
		selectedService : null,
		accountType : 'existing',
		init : function(){
			var self = this;
			Models.Identity.findAll({}).then(function(identities){
				can.batch.start();
				self.attr({
					accountType: 'existing',
					identities: identities,
				});
				self.selectFirstIdentity();
				can.batch.stop();
			});
		},
		serviceLabel : function(){
			return SERVICE_LABELS[this.attr('feed')];
		},
		useExistingAccount : function(){
			return this.attr('accountType') === 'existing';
		},
		addNewAccount : function(){
			return this.attr('accountType') === 'new';
		},
		toggleAccountType : function(ctx, el){
			this.attr('accountType', el.data('accountType'));
		},
		isAuthorized : function(){
			return this.hasIdentityForService(this.attr('feed'));
		},
		setServiceBrandIdentityId : function(id){
			this.attr('service').attr('brand_identity_id', parseInt(id, 10));
		},
		selectFirstIdentity : function(){
			var identities = this.identitiesForCurrentService();
      if(identities.length){
				this.setServiceBrandIdentityId(identities[0].id);
			}
    },
		identitiesForCurrentService : function(){
			var currentService = this.attr('feed');
			return can.grep(this.attr('identities'), function(identity){
				return identity.attr('provider') === getIdentityProvider(currentService);
			});
		},
		hasIdentityForService : function(service){
			var identities = this.attr('identities'),
					length = identities.attr('length');

			for(var i = 0; i < length; i++){
				if(identities.attr(i + '.provider') === getIdentityProvider(service)){
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

			if(this.attr('service.brand_identity_id')){
				return;
			}

			if(!feed){
				throw "You must initialize bh-oauthorizer component with the `feed` attribute";
			}

			this.attr('isAuthorizing', true);

			OAuthConnect(feed).then(function(){
				Models.Identity.findAll({}).then(function(identities){
					self.attr({
						identities : identities,
						isAuthorizing : false,
						accountType: 'existing'
					});
				});
			});
		}
	},
	events : {
		"{scope} isAuthorizing" : function(scope, ev, newVal){
			var self = this;

			if(newVal){
				return;
			}

			setTimeout(function(){
				var identities = self.scope.identitiesForCurrentService();
				if(identities.length){
					identities.sort(compareIdentities);
					self.scope.setServiceBrandIdentityId(identities[0].id);
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
});
