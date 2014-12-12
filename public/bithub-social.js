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
						currentSocket = io('/?embed_id=' + val);
						currentSocket.on('connect', function() {
							console.log('CONNECTED!');
						});
						currentSocket.on('connect_error', function() {
							console.log('CONNECTION ERROR!');
						});

						currentSocket.on('entities', function( msg ) {
							console.log('NEW ENTITY')
							var entity = Models.Bit.model(JSON.parse(msg));
							entity.created();
						});

						currentSocket.on('services', function( msg ) {
							console.log( 'New message from services', msg );
						});

						currentSocket.on('moderation', function( msg ) {
							console.log( 'New message from moderation', msg );
						});
						console.log(currentSocket)
						return val;
					}
				},
				sidebarIsExpanded : {
					value : true,
					serialize: false
				},
				isLoadingService : {
					value : false,
					serialize: false
				},
				bits : {
					Value : Models.Bit.List
				}
			},
			isSidebar : function(){
				return this.attr('page') === 'sidebar';
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

		Models.Service.on('created', function(){
			appState.attr('isLoadingService', true);
		});

		Models.Bit.on('created', function(ev, bit){
			console.log('BIT CREATED', arguments)
			appState.attr('isLoadingService', false);
			appState.attr('bits').unshift(bit)
		});

		stache.registerHelper('pageUrl', function(page, opts){
			var hash = getHash(opts.hash);
			hash.page = can.isFunction(page) ? page() : page;
			return can.route.url(hash, false);
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
