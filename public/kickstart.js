steal(
	'can/map',
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
	function(Map, initView, route, stache, AppState, Models, _reduce, bindModelEvents){

		return function(selector){
			$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
				if(options.type.toLowerCase() !== 'get'){
					options.data = JSON.stringify(originalOptions.data);
					options.contentType = 'application/json';
				}
			});

			Models.Brand.findOne({}).then(function(brand){
				
				var appState = new AppState({
					currentBrand: brand
				});

				can.route.map(appState);

				can.route.ready();

				bindModelEvents(appState);

				var $window = $(window);

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
