steal(
'models',
'lodash/collections/reduce.js', function(Models, _reduce){
	return function(appState){
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
	}
})