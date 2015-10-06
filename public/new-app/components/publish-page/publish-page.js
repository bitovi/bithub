import can from "can";
import initView from "./publish-page.stache!";

import "./publish-page.less!";
import "components/empty-slate/";
import "components/embed-code/";


import Preset from "models/preset";


export default can.Component.extend({
	tag: 'bh-publish-page',
	template: initView,
	scope : {
		currentPreset: null,
		init : function(){
			var self = this;
			this.attr('presets', []);
			Preset.findAll({embed_id: this.attr('appState.currentHub.id')}).then(function(data){
				if(data.length){
					self.attr('presets').replace(data);
					self.attr('currentPreset', data[0]);
				} else {
					self.addDefaultPreset();
				}
			});
		},
		addDefaultPreset : function(){
			var self = this;
			var newPreset = new Preset(can.extend({
				name : 'Default Preset',
				embed_id: this.attr('appState.currentHub.id')
			}, Preset.PREVIEW.serialize()));
			newPreset.save().then(function(preset){
				self.attr('presets').push(preset);
				self.attr('currentPreset', preset);
			});
		},
		selectPresetOrAddNew : function(ctx, el, ev){
			var currentPreset;
			var val = el.val();
			if(val === 'addNewPreset'){
				this.addDefaultPreset();
			} else {
				val = parseInt(val, 10);
				currentPreset = this.attr('presets').filter(function(preset){
					return preset.attr('id') === val;
				})[0];
				this.attr('currentPreset', currentPreset);
			}
		},
		presetIframe : function(){
			var currentPreset = this.attr('currentPreset');
			if(currentPreset){
				var tenantName = this.attr('appState.currentBrand.tenant_name');
				var hub = this.attr('appState.currentHub');
				var hubId = hub.attr('id');
				return this.attr('currentPreset').url(tenantName, hubId);
			}
		}	
	}
});
