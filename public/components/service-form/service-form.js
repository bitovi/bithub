import can from 'can/';
import initView from './service-form.stache!';
import Models from 'models/';

import './service-form.less!';
import 'can/map/define/';

import 'components/service-forms/disqus-forum/';
import 'components/service-forms/facebook-page/';
import 'components/service-forms/facebook-public-page/';
import 'components/service-forms/foursquare-venue/';
import 'components/service-forms/github-org/';
import 'components/service-forms/github-repo/';
import 'components/service-forms/instagram-tag/';
import 'components/service-forms/instagram-user/';
import 'components/service-forms/meetup-group/';
import 'components/service-forms/rss-site/';
import 'components/service-forms/stackexchange-tags/';
import 'components/service-forms/tumblr-blog/';
import 'components/service-forms/tumblr-tag/';
import 'components/service-forms/twitter-followers/';
import 'components/service-forms/twitter-hashtag/';
import 'components/service-forms/twitter-term/';
import 'components/service-forms/twitter-user-timeline/';
import 'components/service-forms/twitter-favorites/';
import 'components/service-forms/twitter-user-retweets/';
import 'components/service-forms/youtube-channel/';
import 'components/service-forms/youtube-playlist/';
import 'components/service-forms/youtube-user/';
import 'components/oauthorizer/';

import 'components/helpers';

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

can.Component.extend({
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

			var self = this;
			var service = this.attr('service');
			var services = this.attr('services');
			this.compute('service');

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
				service: null,
				saveDisabled: false
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
				return;
			}
			var feed = service.attr('feed_name');
			return Models.Service.feeds[feed];
		}
	},
	events : {
		"service:saveDisabled" : function(){
			var self = this;
			setTimeout(function(){
				if(self.element){
					self.element.find('button.save-service').prop('disabled', true);
				}
			}, 1);
			
		},
		"service:saveEnabled" : function(){
			var self = this;
			setTimeout(function(){
				if(self.element){
					self.element.find('button.save-service').prop('disabled', false);
				}
			}, 1);
		}
	},
	helpers : {
		renderForm : function(opts){
			var service = this.attr('service'), feed, type;
			
			if(!service){
				return;
			}

			feed = service.attr('feed_name');
			type = service.attr('type_name');


			if(type && feed){
				return makeTemplate(feed, type)(opts.scope, {
					saveButtons : function(){
						return opts.fn();
					}
				});
			}
		}
	}
});
