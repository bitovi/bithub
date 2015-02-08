steal(
'can/map',
'models',
'lodash/collections/reduce.js',
'connect-liveservice.js',
'can/map/define', 
function(Map, Models, _reduce, connectLiveService){

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
		},
		iframe : function(){
			var currentBrand = this.attr('currentBrand');
			var hubId = this.attr('hubId');
			if(hubId && currentBrand){
				return can.sub('<iframe src="/admin/embed?tenantName={tenantName}&hubId={hubId}&live=true"></iframe>', {
					hubId: hubId,
					tenantName: currentBrand.attr('name')
				});
			}
		}
	});
});
