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
			savePreset : function(ctx, el, ev){
				var self = this;

				ev.preventDefault();

				if(this.attr('isSaving')){
					return;
				}

				this.attr('isSaving', true);
				this.attr('preset').save();
			}
		},
		events : {
			'.clear-preset click' : function(){
				this.element.trigger('clearPreset');
			}
		}
	})
});