/* globals confirm:true */
import can from "can/";
import initView from "./integration.stache!";
import Models from "models/";

import "./integration.less!";
import "components/preset-form/";
import "can/map/define/";
import "can/construct/proxy/";

can.Component.extend({
	tag: 'bh-integration',
	template: initView,
	scope: {
		init : function(){
			this.attr('presets', new Models.Preset.List({embed_id : this.attr('state.hub.id')}));
		},
		integrationCodeForPreset : function(preset){
			var currentBrand = this.attr('state.currentBrand');
			var hub = this.attr('state.hub');
			if(currentBrand && hub && preset){

				return preset.embedCode(
					currentBrand.attr('tenant_name'),
					hub.attr('id'),
					hub.attr('name')
				);
			}
		},
		defaultPresetUrl : function(){
			return this.urlForPreset(Models.Preset.PREVIEW);
		},
		currentPresetUrl : function(){
			return this.urlForPreset(this.currentPreset());
		},
		urlForPreset : function(preset){
			var currentBrand = this.attr('state.currentBrand');
			var hub = this.attr('state.hub');
			
			if(!preset){
				return;
			}
			return preset.fullUrl(currentBrand.attr('tenant_name'), hub.attr('id'));
		},
		defaultIntegrationCode : function(){
			return this.integrationCodeForPreset(Models.Preset.PREVIEW);
		},
		currentPresetIntegrationCode : function(){
			return this.integrationCodeForPreset(this.currentPreset());
		},
		addPreset : function(){
			can.batch.start();
			this.attr('state.customPreset', new Models.Preset({
				embed_id : this.attr('state.hub.id')
			}));
			this.attr('isEditing', false);
			can.batch.stop();
		},
		customPresetExistsAndIsNew : function(){
			var customPreset = this.currentPreset();
			return customPreset && customPreset.isNew();
		},
		currentPreset : function(){
			return this.attr('state').attr('customPreset');
		},
		toggleCurrentPreset : function(preset){
			var currentPreset = this.currentPreset();
			if(currentPreset === preset){
				this.attr('state.customPreset', null);
			} else {
				this.attr('state.customPreset', preset);
			}
		},
		isDefaultPresetOpen : function(){
			return !this.currentPreset();
		},
		clearPreset : function(forceClear){
			var currentPreset = this.currentPreset();
			can.batch.start();
			if(forceClear || currentPreset.isNew()){
				this.attr('state.customPreset', null);
			}
			this.attr('isEditing', false);
			can.batch.stop();
		},
		editPreset : function(preset){
			can.batch.start();
			this.attr('state.customPreset', preset);
			this.attr('isEditing', true);
			can.batch.stop();
		},
		destroyPreset : function(preset){
			var self = this;
			if(confirm('Are you sure?')){
				preset.destroy().then(function(){
					self.clearPreset(true);
				});
			}
		}
	},
	helpers : {
		isCurrentPreset : function(preset, opts){
			var currentPreset = this.currentPreset();
			preset = can.isFunction(preset) ? preset() : preset;

			return preset === currentPreset ? opts.fn() : opts.inverse();
		},
		ifCurrentlyEditingPreset : function(preset, opts){
			var currentPreset = this.currentPreset();
			var isEditing = this.attr('isEditing');
			var check;

			preset = can.isFunction(preset) ? preset() : preset;
			check = preset === currentPreset && isEditing;

			return check ? opts.fn() : opts.inverse();
		}
	},
	events : {
		" savePreset" : function(el, ev){
			var self = this;
			this.scope.currentPreset().save(function(preset){
				can.batch.start();
				var presets = self.scope.attr('presets');
				var index = presets.indexOf(preset);
				if(index === -1){
					presets.unshift(preset);
				}
				self.scope.attr('isEditing', false);
				can.batch.stop();
			});
		},
		'textarea mousedown' : 'selectCode',
		'textarea focus' : function(el, ev){
			el.select();
			setTimeout(function(){
				el.select();
			}, 1);
		},
		selectCode : function(el, ev){
			ev.preventDefault();
			if(el.is(':focus')){
				ev.stopPropagation();
				ev.stopImmediatePropagation();
			}
			el.select();
		},
		'bh-preset-form clearPreset' : function(){
			this.scope.clearPreset();
		}
	}
});
