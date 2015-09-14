import initView from './suggestions.stache!';
import Models from 'models/';
import './suggestions.less!';

export var SuggestionsVM = can.Map.extend({
	enterYourOwnLabel : 'Enter your own',
	pickSuggestionLabel : 'Pick a suggestion',
	allowExtra : false,
	isLoading : true,
	init : function(){
		var self = this;
		this.attr('isLoading', true);
		Models.Suggestion.findAll({
			service: this.attr('service'),
			brandIdentityId: this.attr('brandIdentityId')
		}).then(function(data){
			self.attr({
				suggestions: data,
				isLoading : false
			});
		});
	},
	toggleSuggestion : function(suggestion){
		var currentSuggestion = this.attr('val');
		var newSuggestion = suggestion.attr('id');

		if(currentSuggestion === newSuggestion){
			this.attr('val', null);
		} else {
			this.attr('val', suggestion.attr('id'));
		}
		
	},
	hasExtra : function(){
		var suggestions = this.attr('suggestions');
		var length = suggestions.attr('length');
		var val = this.attr('val');

		for(var i = 0; i < length; i++){
			if(suggestions[i].id === val){
				return false;
			}
		}
		return !!this.attr('allowExtra');
	}
});

can.Component.extend({
	tag : 'bh-suggestions',
	template : initView,
	scope : SuggestionsVM,
	helpers : {
		isSelected : function(suggestion, opts){
			suggestion = can.isFunction(suggestion) ? suggestion() : suggestion;
			if(suggestion.attr('id') === this.attr('val')){
				return opts.fn();
			}
			return opts.inverse();
		}
	}
});
