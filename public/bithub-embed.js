steal(
'models/appstate.js',
'./embed.stache!',
'models/bit.js',
'models/hub.js',
'connect-liveservice.js',
'bits',
'can/route',
'style',
function(AppState, embedView, Bit, Hub, connectLiveService){

	var params = can.deparam(window.location.search.substr(1));
	var hubId = params.hubId;
	var tenantName = params.tenantName;
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
	})()

	Hub.findOne({id: hubId}).then(function(hub){
		can.route.map(appState);

		can.route.ready();

		appState.attr({
			hubId : hubId,
			hub: hub,
			tenant : tenantName
		});

		if(params.live){
			liveService = connectLiveService(hubId);
			if(liveService){
				liveService.on('entities', can.proxy(Bit.messageFromLiveService, Bit));
			}
			Bit.on('created', function(ev, bit){
				var serviceIds = bit.attr('service_ids');
				var bits = appState.attr('bits');

				bits.unshift(bit);
				
				triggerPartition(bits);

				window.parent && window.parent.postMessage({
					type : 'loadedBits',
					payload : serviceIds.join(',')
				}, 'http://' + EMBED_ENDPOINT);

			});
		}

		$('body').addClass('embed');

		$('#app').html(embedView({
			state: appState
		}));
	});

	
});