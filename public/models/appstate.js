steal(
'can/map',
'models',
'lodash/collections/reduce.js',
'connect-liveservice.js',
'communicator',
'can/map/define', 
'can/construct/proxy',
'can/map/delegate',
function(Map, Models, _reduce, connectLiveService, Communicator){

	var CURRENT_IFRAME;

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
			embedType : {
				get : function(){
					if(this.attr('page') === 'sidebar'){
						if(this.attr('panel') === 'integration'){
							return 'preview';
						}
						return 'admin';
					}
				},
				serialize: false
			},
			iframe : {
				get : function(){
					var src = this.attr('iframeSrc');
					var iframe;

					if(src){
						if(!CURRENT_IFRAME){
							iframe = document.createElement('iframe');
							console.log( this.iframeSrc())
							iframe.src = this.iframeSrc();

							CURRENT_IFRAME = iframe;
						}

						return CURRENT_IFRAME;
					}
				}
			},
			iframeSrc : {
				get : function(){
					var currentBrand = this.attr('currentBrand');
					var hubId = this.attr('hubId');

					if(hubId && currentBrand){
						return this.attr('preset').url(currentBrand.attr('tenant_name'), hubId);
					}
				},
				serialize: false
			},
			preset : {
				get : function(){
					var embedType = this.embedType();
					var customPreset;

					console.log('EMBED TYPE', embedType)

					if(embedType === 'admin'){
						return Models.Preset.ADMIN;
					} else {
						customPreset = this.attr('customPreset');
						return customPreset || Models.Preset.PREVIEW;
					}
				},
				serialize: false,
			},
			customPreset: {
				serialize: false
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
					self.bitsWereLoaded(payload);
				}
			});
		},
		updateIframeAttrs : function(){
			var preset = this.attr('preset');
			var currentBrand = this.attr('currentBrand');
			var hubId = this.attr('hubId');
			var newAttrs;

			if(preset && currentBrand && hubId){
				newAttrs = preset.embedAttrs(currentBrand.attr('tenant_name'), hubId);
				this.communicator.send('updateAttrs', newAttrs);
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
		theme : function(){
			var preset = this.attr('preset');
			return preset.attr('config.theme') || 'light';
		},
		isSidebar : function(){
			return this.attr('page') === 'sidebar' && this.attr('hubId');
		},
		embedType : function(){
			return this.attr('embedType');
		},
		embedTypeTitle : function(){
			var titles = {
				admin: 'Administration',
				preview: 'Preview'
			};
			return titles[this.embedType()];
		}
	});
});
