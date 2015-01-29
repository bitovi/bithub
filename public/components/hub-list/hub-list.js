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
				expandedRows : {
					Value : Array
				},
				hubs : {
					value : function(){
						return new Models.Hub.List({});
					}
				}
			},
			createAndEditHub : function(){
				new Models.Hub({
					name: ''
				}).save(function(hub){
					console.log('HUB', hub)
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
			},
			toggleExpandedRow : function(hub){
				var hubId = hub.attr('id'),
					expandedRows = this.attr('expandedRows'),
					index = expandedRows.indexOf(hubId);

				if(index === -1){
					expandedRows.push(hubId);
				} else {
					expandedRows.splice(index, 1);
				}
			}
		},
		helpers : {
			isExpandedRow : function(hub, opts){
				hub = can.isFunction(hub) ? hub() : hub;
				console.log(this.attr('expandedRows').attr('length'), this.attr('expandedRows')) // bind to the length

				return this.attr('expandedRows').indexOf(hub.attr('id')) > -1 ? opts.fn() : opts.inverse();
			},
			formatConnectedServices : function(services){
				var serviceNames;
				services = can.isFunction(services) ? services() : services;

				if(!services){
					return;
				}

				if(services.isPending()){
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