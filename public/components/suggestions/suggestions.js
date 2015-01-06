steal(
'can/component',
'./suggestions.stache!',
'models',
'./suggestions.less!',
function(Component, initView, Models){
	return Component.extend({
		tag : 'bh-suggestions',
		template : initView,
		scope : {
			isLoading : true,
			init : function(){
				var self = this;
				Models.Suggestion.findAll({service: this.attr('service')}).then(function(data){
					self.attr({
						suggestions: data,
						isLoading : false
					});
				});
			},
			toggleSuggestion : function(suggestion){
				var currentSuggestion = this.attr('val'),
					newSuggestion = suggestion.attr('id');

				if(currentSuggestion === newSuggestion){
					this.attr('val', null);
				} else {
					this.attr('val', suggestion.attr('id'));
				}
				
			}
		},
		helpers : {
			isSelected : function(suggestion, opts){
				suggestion = can.isFunction(suggestion) ? suggestion() : suggestion;
				if(suggestion.attr('id') === this.attr('val')){
					return opts.fn();
				}
				return opts.inverse();
			}
		}
	})
});