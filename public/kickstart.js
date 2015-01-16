steal(
	'can/map',
	'./bithub-social.stache!',
	'can/route',
	'can/view/stache',
	'models/appstate.js',
	'models',
	'lodash/collections/reduce.js',
	'can/map/define',
	'components',
	'components/helpers.js',
	'fixtures',
	function(Map, initView, route, stache, AppState, Models, _reduce){

		return function(selector){
			$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
				if(options.type.toLowerCase() !== 'get'){
					options.data = JSON.stringify(originalOptions.data);
					options.contentType = 'application/json';
				}
			});

			var appState = new AppState;

			can.route.map(appState);

			can.route.ready();

			Models.Service.on('saving', function(ev, service){
				var loadingServices = appState.attr('loadingServices');
				var index = loadingServices.indexOf(service);

				if(index > -1){
					loadingServices.splice(index, 1);
				}
				
				loadingServices.unshift(service);
			});


			Models.Service.on('errored', function(ev, service){
				var loadingServices = appState.attr('loadingServices');
				var index = loadingServices.indexOf(service);

				loadingServices.splice(index, 1);
			});

			Models.Service.on('destroyed', function(ev, service){
				var loadingServices = appState.attr('loadingServices'),
					index = loadingServiced.indexOf(service);

				if(index > -1){
					loadingServices.splice(index, 1);
				}
			});

			Models.Bit.on('created', function(ev, bit){
				var serviceIds = bit.attr('service_ids'),
					loadingServices = appState.attr('loadingServices'),
					loadingServiceIds = _reduce(loadingServices, function(acc, service){
						acc[service.attr('id')] = service;
						return acc;
					}, {}),
					index;

				appState.attr('bits').unshift(bit);

				for(var i = 0; i < serviceIds.length; i++){
					if(loadingServiceIds[serviceIds[i]]){
						index = loadingServices.indexOf(serviceIds[i]);
						loadingServices.splice(index, 1);
					}
				}
			});

			var $window = $(window);

			var calculateScrollAndHeight = function(){
				return {
					scrollTop : $window.scrollTop(),
					scrollHeight : $window.height()
				}
			}

			$window.scroll(function(){
				appState.attr(calculateScrollAndHeight());
			});

			$window.on('resize', function(){
				appState.attr(calculateScrollAndHeight());
			});

			$(selector).html(initView({
				state: appState
			}, {
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
		}

	});
