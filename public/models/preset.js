steal(
'can/model',
'can/construct/super',
'can/map/define',
'can/list/promise',
'can/map/backup',
function(Model){

	var EMBED_TEMPLATE = '<a href="http://{embedEndpoint}{embedUrl}" class="bithub-embed">{hubName} Embed</a><script src="http://{embedEndpoint}/embed.js"></script>'

	var dasherize  = function(str) {
		return str.replace(/[A-Z]/g, function(char, index) {
			return (index !== 0 ? '-' : '') + char.toLowerCase();
		});
	};

	var Preset = Model.extend({
		resource: '/api/v3/presets',
	}, {
		define : {
			config : {
				value : function(){
					return {
						theme: 'light',
						view: 'public'
					}
				}
			}
		},
		embedAttrs : function(tenantName, hubId){
			return can.extend({
				hubId: hubId,
				tenant: tenantName
			}, this.serialize().preset.config || {});
		},
		url : function(tenantName, hubId){
			var attrs = this.embedAttrs(tenantName, hubId);
			return '/embed?' + can.param(attrs);
		},
		fullUrl : function(tenantName, hubId){
			return can.sub("http://{embedEndpoint}{embedUrl}", {
				embedEndpoint: EMBED_ENDPOINT,
				embedUrl: this.url(tenantName, hubId)
			});
		},
		embedCode : function(tenantName, hubId, hubName){
			var attrs = this.embedAttrs(tenantName, hubId);

			return can.sub(EMBED_TEMPLATE, {
				embedEndpoint : EMBED_ENDPOINT,
				embedUrl: this.url(tenantName, hubId),
				hubName: hubName
			});
		},
		serialize : function(){
			var data = this._super.apply(this, arguments);
			if(!data.config){
				data.config = {};
			}
			if(!data.config.view){
				data.config.view = 'public';
			}
			if(!data.config.live){
				delete data.config.live;
			}
			return {
				preset: data
			};
		}
	});

	Preset.ADMIN = new Preset({
		config: {
			live: true,
			view: 'admin',
			order: 'created_at:desc',
			filter: 'all'
		}
	});

	Preset.PREVIEW = new Preset({
		name : 'Default Preset',
		config: {
			live: false
		}
	});

	return Preset;
})
