steal(
'can/component',
'./integration.stache!',
'models',
'./integration.less!',
'components/preset-form',
'can/map/define',
function(Component, initView, Models){

	return Component.extend({
		tag: 'bh-integration',
		template: initView,
		scope: {
			init : function(){
				this.attr('presets', new Models.Preset.List({
					preset: {
						embedId : this.attr('hub.id')
					}
				}));
			},
			integrationCodeForPreset : function(preset){
				var currentBrand = this.attr('state.currentBrand');
				var hub = this.attr('hub');
				var tenantName, hubId;
				if(currentBrand && hub && preset){

					return preset.embedCode(
						currentBrand.attr('tenant_name'),
						hub.attr('id'),
						hub.attr('name')
					);
				}
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
					embedId : this.attr('hub.id')
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
			'textarea focus' : function(el, ev){
				ev.preventDefault();
				if(el.is(':focus')){
					ev.stopPropagation();
					ev.stopImmediatePropagation();
				} else {
					el.select();
				}
			},
			'bh-preset-form clearPreset' : function(){
				this.scope.clearPreset();
			}
		}
	})
});