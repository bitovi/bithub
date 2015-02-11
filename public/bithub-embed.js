steal(
'models/embed_appstate.js',
'./embed.stache!',
'models/bit.js',
'models/hub.js',
'bit-list',
'communicator',
'bits',
'can/route',
'style',
function(AppState, embedView, Bit, Hub, BitList, Communicator){

	var params = can.deparam(window.location.search.substr(1));
	var liveService;

	var appState = new AppState();

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
			}
		});

		var theme = params.theme || 'light';

		can.route.map(appState);
		can.route.ready();

		appState.attr('hub', hub);
		appState.setAttrs(params);

		Bit.on('lifecycle', function(ev, bit){
			var serviceIds = bit.attr('service_ids');
			var bits = appState.attr('bits');
			var index;
			var isLive = appState.isLive();

			if(appState.isPublic()){
				if(!bit.attr('is_approved')){
					index = bits.indexOf(bit);
					if(index > -1){
						bits.splice(index, 1);
					}
				} else {
					isLive && bits.place(bit);
				}
				
			} else {
				if(isLive && bits.indexOf(bit) === -1){
					bits.unshift(bit);
				}
			}
			
			triggerPartition(bits);

			if(serviceIds){
				communicator.send('loadedBits', serviceIds);
			}
			

		});

		$('body').addClass('embed ' + theme + '-theme');

		var initApp = function(){
			var div = $('<div id="app" />');
			
			$('#app-wrapper').html(div);

			new BitList(div, {
				state : appState
			});
		}

		appState.on('view', function(){
			appState.reset();
			initApp();
		});

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