steal(
'models/appstate.js',
'./embed.stache!',
'models/bit.js',
'connect-liveservice.js',
'bits',
'can/route',
'style',
function(AppState, embedView, Bit, connectLiveService){

	var params = can.deparam(window.location.search.substr(1));
	var hubId = params.hubId;
	var tenantName = params.tenantName;
	var liveService;

	var appState = new AppState();
	can.route.map(appState);

	can.route.ready();

	appState.attr({
		hubId : hubId,
		tenant : tenantName
	});

	if(params.live){
		liveService = connectLiveService(hubId);
		if(liveService){
			liveService.on('entities', can.proxy(Bit.messageFromLiveService, Bit));
		}
		Bit.on('created', function(ev, bit){
			var serviceIds = bit.attr('service_ids');

			appState.attr('bits').unshift(bit);

			window.parent && window.parent.postMessage({
				type : 'loadedBits',
				payload : serviceIds.join(',')
			}, 'http://' + EMBED_ENDPOINT);

		});
	}

	$('body').addClass('no-background');

	$('#app').html(embedView({
		state: appState
	}))
});