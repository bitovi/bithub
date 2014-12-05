steal(
'can/component',
'./hub-list.stache!',
'models',
'lodash/collections/map.js',
'lodash/collections/reduce.js',
'style',
'./hub-list.less!',
'can/map/define',
function(Component, initView, Models, _map, _reduce){

	Component.extend({
		tag : 'bh-hub-list',
		template : initView,
		scope : {
			define : {
				expandedHub : {
					value : null
				},
				hubs : {
					value : function(){
						return new Models.Hub.List({});
					}
				}
			},
			createAndEditHub : function(){
				new Models.Hub({
					name : 'Untitled Hub'
				}).save(function(hub){
					can.route.attr({
						hubId : hub.id,
						page : 'sidebar',
						panel : 'services'
					})
				})
			},
			destroyHub : function(hub){
				if(confirm('Are you sure?')){
					hub.destroy();
				}
			}
		},
		helpers : {
			formatConnectedServices : function(services){
				var serviceNames;
				services = can.isFunction(services) ? services() : services;

				if(!services){
					return;
				}

				serviceNames = can.map(services, function(service){
					return service.attr('feed_name');
				});

				return _map(_reduce(serviceNames, function(acc, service){
					if(acc[service]){
						acc[service] += 1; 
					} else {
						acc[service] = 1;
					}
					return acc;
				}, {}), function(occurenceCount, service){
					if(occurenceCount > 1){
						return service + ' (' + occurenceCount + ')';
					}
					return service;
				}).join(', ');
			}
		}
	});

})