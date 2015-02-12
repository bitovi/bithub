steal(
'can/model',
'can/construct/super',
'can/map/define',
'can/list/promise',
function(Model){

	var EMBED_TEMPLATE = '<a href="http://{embedEndpoint}{embedUrl}" {embedData} class="bithub-embed">{hubName} Embed</a><script src="http://{embedEndpoint}/admin/embed.js"></script>'

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
			return '/admin/embed?' + can.param(attrs);
		},
		embedCode : function(tenantName, hubId, hubName){
			var attrs = this.embedAttrs(tenantName, hubId);
			var dataAttrs = [];

			for(var k in attrs){
				dataAttrs.push('data-' + dasherize(k) + '="' + attrs[k] + '"')
			}

			return can.sub(EMBED_TEMPLATE, {
				embedEndpoint : EMBED_ENDPOINT,
				embedUrl: this.url(tenantName, hubId),
				embedData: dataAttrs.join(' '),
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
			view: 'admin'
		}
	});

	Preset.PREVIEW = new Preset({
		config: {
			live: false
		}
	});

	return Preset;
})