steal(
'models/embed_appstate.js',
'./embed.stache!',
'models/bit.js',
'models/hub.js',
'bit-list',
'connect-liveservice.js',
'bits',
'can/route',
'style',
function(AppState, embedView, Bit, Hub, BitList, connectLiveService){

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

	var kickstart = function(hub){
		var isPublic = !hub;

		can.route.map(appState);

		can.route.ready();

		appState.attr({
			hubId : hubId,
			hub: hub,
			tenant : tenantName
		});

		if(params.live){
			liveService = connectLiveService(hubId, isPublic ? tenantName : null);
			if(liveService){
				liveService.on('entities', can.proxy(Bit.messageFromLiveService, Bit));
			}
			Bit.on('created', function(ev, bit){
				var serviceIds = bit.attr('service_ids');
				var bits = appState.attr('bits');
				var index;

				if(isPublic){
					if(!bit.attr('is_approved')){
						index = bits.indexOf(bit);
						if(index > -1){
							bits.splice(index, 1);
						}
					} else {
						bits.place(bit);
					}
					
				} else {
					if(bits.indexOf(bit) === -1){
						bits.unshift(bit);
					}
				}
				
				triggerPartition(bits);


				if(serviceIds){
					window.parent && window.parent.postMessage({
						type : 'loadedBits',
						payload : serviceIds.join(',')
					}, 'http://' + EMBED_ENDPOINT);
				}
				

			});
		}

		$('body').addClass('embed');

		new BitList($('#app'), {
			state : appState
		});
	}

	Hub.findOne({id: hubId}).then(function(hub){
		kickstart(hub);
	}, function(){
		kickstart();
	});
});