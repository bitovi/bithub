/* globals EMBED_ENDPOINT:true */

import can from "can/";

import 'can/construct/super/';
import 'can/map/define/';
import 'can/list/promise/';
import 'can/map/backup/';

var EMBED_TEMPLATE = '<a href="http://{embedEndpoint}{embedUrl}" class="bithub-embed">{hubName} Embed</a><script src="http://{embedEndpoint}/embed.js"></script>';

var Preset = can.Model.extend({
	resource: '/api/v3/presets',
}, {
	define : {
		config : {
			value : function(){
				return {
					theme: 'light',
					view: 'public'
				};
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
		order: 'grouped-by-date',
		decision: 'pending'
	}
});

Preset.PREVIEW = new Preset({
	name : 'Default Preset',
	config: {
		live: false,
		decision: 'approved'
	}
});

export default Preset;
