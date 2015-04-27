steal(
	'can/map',
	'can/control',
	'./bithub-social.stache!',
	'can/route',
	'can/view/stache',
	'models/appstate.js',
	'models',
	'lodash/collections/reduce.js',
	'./bind-model-events.js',
	'can/map/define',
	'components',
	'components/helpers.js',
	'fixtures',
	function(Map, Control, initView, route, stache, AppState, Models, _reduce, bindModelEvents){

		return function(selector){
			var PresetChangeUpdater = Control.extend({
				'{appState} preset' : 'updateIframeAttrs',
				'{appState} customPreset change' : 'updateIframeAttrs',
				'{appState.adminPreset} change' : 'updateIframeAttrs',
				updateIframeAttrs : function(){
					var self = this;
					clearTimeout(this.__updateIframeAttrs);
					this.__updateIframeAttrs = setTimeout(function(){
						self.options.appState.updateIframeAttrs();
					});
				}
			});

			$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
				if(options.type.toLowerCase() !== 'get'){
					options.data = JSON.stringify(originalOptions.data);
					options.contentType = 'application/json';
				}
			});

			$.when(Models.Brand.findOne({}), Models.Subscription.findOne({})).done(function(brand, subscription){

				
				var appState = new AppState({
					currentBrand: brand,
					currentSubscription: subscription,
					embedType : 'admin'
				});

				new PresetChangeUpdater(document.documentElement, {
					appState : appState
				});

				can.route('', {page: 'hub-list'});
				can.route(':page');
				can.route(':page/:panel');
				can.route(':page/:panel/:hubId');
				can.route(':page/:panel/:hubId');

				can.route.map(appState);

				can.route.ready();

				bindModelEvents(appState);

				var $window = $(window);

				stache.registerHelper('ifCanAddHub', function(hubs, opts){
					hubs = can.isFunction(hubs) ? hubs() : hubs;
					var canAddHub = appState.attr('currentSubscription').canAddHub(hubs);
					return canAddHub ? opts.fn() : opts.inverse();
				});

				stache.registerHelper('ifCanAddService', function(services, feed, type, opts){
					feed = can.isFunction(feed) ? feed() : feed;
					type = can.isFunction(type) ? type() : type;
					services = can.isFunction(services) ? services() : services;
					var canAddService = appState.attr('currentSubscription').canAddService(services, feed, type);

					return canAddService ? opts.fn() : opts.inverse();
				})


				$(selector).html(initView({
					state: appState
				}, {
					renderIframe : function(iframe, opts){
						iframe = can.isFunction(iframe) ? iframe() : iframe;
						return iframe;
					},
					renderPage : function(){
						var page = can.route.attr('page') || "hub-list",
								template = can.stache('<bh-' + page + ' state="{state}"></bh-' + page + '>');

						return template(this);
					},
					pageLink : function(page, title){
						page = can.isFunction(page) ? page() : page;
						title = can.isFunction(title) ? title() : title;

						var currentPage = can.route.attr('page'),
								props = {
									'class' : 'btn '
								};

						props['class'] += page === currentPage ? 'btn-default' : 'btn-link';

						return can.route.link(title, {page: page}, props, false);
					}
				}));
			});

			
		}

	});
