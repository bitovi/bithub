steal(
'models/embed_appstate.js',
'./embed.stache!',
'models/bit.js',
'models/hub.js',
'bit-list',
'communicator',
'bits',
'can/route',
'style/embed.less!',
function(AppState, embedView, Bit, Hub, BitList, Communicator){

	var params = can.deparam(window.location.search.substr(1));
	var liveService;
	var isLoadedFromIframe = window.parent !== window;
	var appState = new AppState();

	var bodyClasses = [(isLoadedFromIframe ? 'iframe-context' : 'page-context'), 'embed'];

	var triggerPartition = (function(){
		var partitionTimeout;
		return function(bits){
			clearTimeout(partitionTimeout);
			partitionTimeout = setTimeout(function(){
				can.trigger(bits, 'partition');
			}, 100);
		}
	})();

	var kickstart = function(hub){
		var communicator = Communicator.bind(window.parent, {
			updateAttrs : function(data){
				appState.setAttrs(data);
			},
			reset : function(){
				resetApp();
			}
		});

		bodyClasses.push((params.theme || 'light') + '-theme');

		//can.route.map(appState);
		//can.route.ready();



		appState.attr('hub', hub);
		appState.setAttrs(params);
		appState.connectLiveService();

		Bit.on('lifecycle', function(ev, bit){
			var serviceIds = bit.attr('service_ids');
			var bits = appState.attr('bits');
			var index;
			var isLive = appState.isLive();

			if(appState.isPublic()){
				isLive && bit.attr('is_approved') && bits.place(bit);
			} else {
				if(isLive && bits.indexOf(bit) === -1){
					bits.unshift(bit);
				}
			}

			triggerPartition(bits);

			if( serviceIds && (params.view != 'public') ){
				communicator.send('loadedBits', serviceIds);
			}

		});

		Bit.on('disapproved', function(ev, bit){
			var bits = appState.attr('bits');
			var index = bits.indexOf(bit);
			if(appState.isPublic() && index > -1){
				bits.splice(index, 1);
			}
		});

		$('body').addClass(bodyClasses.join(' '));

		var initApp = function(){
			var div = $('<div id="app" />');

			$('#app-wrapper').html(div);

			new BitList(div, {
				state : appState
			});
		}

		var resetApp = (function(){
			var timeout;
			return function(){
				clearTimeout(timeout);
				setTimeout(function(){
					appState.reset();
					initApp();
				}, 1);
			}
		})();

		appState.on('view', resetApp);
		appState.on('order', resetApp);
		appState.on('filter', resetApp);

		appState.on('theme', function(ev, newTheme){
			$('body').removeClass('dark-theme light-theme').addClass(newTheme + '-theme');
		});

		initApp();
	}

	Hub.findOne({id: params.hubId}).then(function(hub){
		kickstart(hub);
	}, function(){
		kickstart();
	});
});
