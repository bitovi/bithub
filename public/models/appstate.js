import can from "can/";
import Models from 'models/';
import _reduce from 'lodash-amd/modern/collection/reduce';
import connectLiveService from 'connect-liveservice';
import Communicator from 'communicator/';
import 'can/map/define/';
import 'can/construct/proxy/';
import 'can/map/delegate/';

var CURRENT_IFRAME;

var PAGE_TITLES = {
	'hub-list' : 'Hub List',
	'services' : 'Services',
	'integration' : 'Integration',
	'moderation' : 'Moderation',
	'analytics' : 'Analytics',
	'payments' : 'Payments',
	'organization-settings' : 'Organization Accounts',
	'user-settings' : 'User Settings'
};

var getPageTitle = function(val, appState){
	if(val === 'sidebar'){
		val = appState.attr('panel') || 'services';
	}

	return PAGE_TITLES[val];
};

var setTitle = function(val, appState){
	$('title').html('BitHub &mdash; ' + getPageTitle(val, appState));
};

export default can.Map.extend({
	define : {
		page : {
			value : 'hub-list',
			set : function(val){
				this.removeAttr('customPreset');
				setTitle(val, this);
				return val;
			}
		},
		panel : {
			set : function(val){
				setTitle(val, this);
				return val;
			}
		},
		currentSubscription : {
			serialize: false
		},
		currentAccount: {
			serialize: false
		},
		currentOrganization : {
			serialize: false
		},
		hubId : {
			set : function(val){
				var liveService = connectLiveService(val, this.attr('currentBrand').attr('tenant_name'));
				var self = this;

				this.attr('bits').splice(0);

				if(liveService){


					liveService.on('services', can.proxy(Models.Service.messageFromLiveService, Models.Service));

					liveService.on('services', function(msg){
						var loadingServices = self.attr('loadingServices');
						var index, service;
						if(typeof msg === 'string'){
							msg = JSON.parse(msg);
						}

						if(msg.service.empty_results || msg.service.has_errors){
							service = loadingServices.filter(function(s){
								return s.id === msg.service.id;
							})[0];
							index = loadingServices.indexOf(service);
							if(index > -1){
								loadingServices.splice(index, 1);
							}
						}
					});
				}

				return val;
			},
			remove : function(){
				CURRENT_IFRAME = null;
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
						iframe = $('<iframe src="' + src + '"></iframe>');
						CURRENT_IFRAME = iframe[0];
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
		adminPreset : {
			value : Models.Preset.ADMIN,
			serialize: false
		},
		defaultPreviewPreset : {
			value : Models.Preset.PREVIEW,
			serialize: false
		},
		preset : {
			get : function(){
				var embedType = this.embedType();
				var customPreset;

				if(embedType === 'admin'){
					return this.attr('adminPreset');
				} else {
					customPreset = this.attr('customPreset');
					return customPreset || this.attr('defaultPreviewPreset');
				}
			},
			set : function(val){
				var embedType            = this.embedType();
				var adminPreset          = this.attr('adminPreset');

				if(embedType === 'admin'){
					adminPreset.attr('config').attr(val.attr ? val.attr() : val);
					return val;
				}
			},
			serialize : function(){
				var embedType            = this.embedType();
				var adminPreset          = this.attr('adminPreset');
				var adminParams;
				if(adminPreset){
					adminPreset.attr();
				}
				

				if(embedType === 'admin'){
					adminParams = {
						order: adminPreset.attr('config.order'),
						decision: adminPreset.attr('config.decision')
					};

					if(adminPreset.attr('config.service_id')){
						adminParams.service_id = adminPreset.attr('config.service_id');
					}

					return adminParams;
				}
			}
		},
		customPreset: {
			serialize: false
		},
		hub : {
			serialize : false,
			get : function(lastSetValue, setAttrValue){
				Models.Hub.findOne({id: this.attr('hubId')})
					.then(function(hub){
						setAttrValue(hub);
					});
			}
		},
		services : {
			get : function() {
				return new Models.Service.List({
					embed_id: this.attr('hubId')
				});
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
	resetEmbed : function(){
		this.communicator.send('reset');
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
	isAdminEmbed : function(){
		var preset = this.attr('preset');
		return preset && preset.attr('config.view') === 'admin';
	},
	theme : function(){
		var preset = this.attr('preset');
		return (preset && preset.attr('config.theme')) || 'light';
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
	},
	isAnalyticsPageActive : function(){
		return this.attr('page') === 'analytics';
	},
	setDecision : function(ctx, el, ev){
		var decision = el.data('decision');
		this.attr('preset.config.decision', decision);
	}
});
