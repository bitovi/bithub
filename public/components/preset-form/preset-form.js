steal(
'can/component',
'./preset-form.stache!',
'./preset-form.less!',
function(Component, initView){
	return Component.extend({
		tag: 'bh-preset-form',
		template: initView,
		scope: {
			isSaving: false,
			init : function(){
				this.attr('preset').backup();
				this.attr('preset.config').backup();
			},
			savePreset : function(ctx, el, ev){
				var self = this;

				ev.preventDefault();

				if(this.attr('isSaving')){
					return;
				}

				this.attr('isSaving', true);
				el.closest('bh-integration').trigger('savePreset')
			}
		},
		events : {
			'.clear-preset click' : function(){
				this.scope.attr('preset').restore();
				this.scope.attr('preset.config').restore();
				this.element.trigger('clearPreset');
			}
		}
	})
});