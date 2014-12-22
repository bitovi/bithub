steal(
	'can/map',
	'./bithub-social.stache!',
	'can/route',
	'can/view/stache',
	'models',
	'lodash/collections/reduce.js',
	'can/map/define',
	'components',
	'fixtures',
	function(Map, initView, route, stache, Models, _reduce){

		var currentSocket;

		$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
			if(options.type.toLowerCase() !== 'get'){
				options.data = JSON.stringify(originalOptions.data);
				options.contentType = 'application/json';
			}
		});

		var AppState = Map.extend({
			define : {
				page : {
					value : 'hub-list'
				},
				hubId : {
					set : function(val){
						if(currentSocket && currentSocket){
							currentSocket.close();
						}

						if(typeof io === 'undefined') return;

						currentSocket = io('/?embed_id=' + val, { multiplex: false });
						currentSocket.on('connect', function() {
							console.log('CONNECTED!');
						});
						currentSocket.on('connect_error', function() {
							console.log('CONNECTION ERROR!');
						});

						currentSocket.on('entities', function( msg ) {
							var parsed = JSON.parse(msg);
							console.log('NEW ENTITY');

							parsed._isFromLiveService = true;

							var entity = Models.Bit.model(parsed);
							entity.created();
						});

						currentSocket.on('services', function( msg ) {
							console.log( 'New message from services', msg );
						});

						currentSocket.on('moderation', function( msg ) {
							console.log( 'New message from moderation', msg );
						});
						return val;
					}
				},
				sidebarIsExpanded : {
					value : true,
					serialize: false
				},
				loadingServices : {
					value : [],
					serialize: false
				},
				bits : {
					Value : Models.Bit.List,
					serialize: false
				},
				scrollTop : {
					value : 0,
					serialize: false
				},
				scrollHeight: {
					value : 0,
					serialize: false
				}
			},
			isSidebar : function(){
				return this.attr('page') === 'sidebar' && this.attr('hubId');
			}
		});

		var getHash = function(optsHash){
			return _reduce(optsHash || {}, function(acc, val, key){
				acc[key] = can.isFunction(val) ? val() : val;
				return acc;
			}, {});
		};

		var appState = new AppState;

		can.route.map(appState);

		can.route.ready();

		Models.Service.on('saving', function(ev, service){
			appState.attr('loadingServices').unshift(service);
		});

		Models.Bit.on('created', function(ev, bit){
			var serviceIds = bit.attr('service_ids'),
				loadingServices = appState.attr('loadingServices'),
				loadingServiceIds = _reduce(loadingServices, function(acc, service){
					acc[service.attr('id')] = service;
					return acc;
				}, {}),
				index;

			appState.attr('bits').place(bit);

			for(var i = 0; i < serviceIds.length; i++){
				if(loadingServiceIds[serviceIds[i]]){
					index = loadingServices.indexOf(serviceIds[i]);
					loadingServices.splice(index, 1);
				}
			}
		});

		stache.registerHelper('pageUrl', function(page, opts){
			var hash = getHash(opts.hash);
			hash.page = can.isFunction(page) ? page() : page;
			return can.route.url(hash, false);
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

		$('#app').html(initView({
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

	});
