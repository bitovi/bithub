steal(
'can/map',
'models',
'lodash/collections/reduce.js',
'connect-liveservice.js',
'communicator',
'can/map/define', 
function(Map, Models, _reduce, connectLiveService, Communicator){

	return Map.extend({
		define : {
			page : {
				value : 'hub-list'
			},
			hubId : {
				set : function(val){
					var liveService = connectLiveService(val);

					this.attr('bits').splice(0);

					if(liveService){
						liveService.on('services', can.proxy(Models.Service.messageFromLiveService, Models.Service));
					}

					return val;
				},
				remove : function(){
					this.attr('bits').splice(0);
				}
			},
			iframe : {
				get : function(){
					var currentBrand = this.attr('currentBrand');
					var hubId = this.attr('hubId');
					var url = "/admin/embed?tenantName={tenantName}&hubId={hubId}&live=true";
					var iframe;

					if(hubId && currentBrand){

						iframe = document.createElement('iframe');
						iframe.src = can.sub(url, {
							hubId: hubId,
							tenantName: currentBrand.attr('name')
						});

						return iframe;
					}
				}
			},
			hub : {
				serialize : false,
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
			},
			currentBrand : {
				serialize: false
			}
		},
		init : function(){
			var self = this;
			this.communicator = Communicator.bind(this.compute('iframe'), {
				loadedBits : function(payload){
					self.bitsWereLoaded(payload.split(','));
				}
			});
		},
		bitsWereLoaded : function(serviceIds){
			var loadingServices = this.attr('loadingServices');
			var loadingServicesByIds = _reduce(loadingServices, function(acc, service){
					acc[service.attr('id') + ""] = service;
					return acc;
				}, {});
			var index;

			for(var i = 0; i < serviceIds.length; i++){
				if(loadingServicesByIds[serviceIds[i]]){
					index = loadingServices.indexOf(loadingServicesByIds[serviceIds[i]]);
					loadingServices.splice(index, 1);
				}
			}
		},
		isSidebar : function(){
			return this.attr('page') === 'sidebar' && this.attr('hubId');
		}
	});
});
