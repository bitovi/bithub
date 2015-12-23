import can from "can";
import initView from './instagram-user.stache!';
import './instagram-user.less!';
import 'selectize';

can.Component.extend({
	tag : 'bh-instagram-user-service',
	template : initView,
	scope : {
		isLoading : false,
		init : function(){
			this.attr('currentSuggestions', []);
		},
		setDisplayName : function(id){
			var currentSuggestions = this.attr('currentSuggestions');
			var length = currentSuggestions.length;

			if(id){
				for(var i = 0; i < length; i++){
					if(id === currentSuggestions[i].id){
						this.attr('map.config.display_name', currentSuggestions[i].username);
					}
				}
			} else {
				this.attr('map.config.display_name', '');
			}
		}
	},
	helpers : {
		instagramSuggest : function(){
			var self = this;
			return function(el){
				$(el).selectize({
					valueField: 'id',
					labelField: 'username',
					searchField: 'username',
					create: false,
					allowEmptyOption : true,
					load: function(query, callback){
						if(!query.length){
							return callback();
						}
						self.attr('isLoading', true);
						$.ajax({
							url: '/api/v3/services/suggestions/instagram',
							data: {
								username: query
							},
							error : function(){
								self.attr('isLoading', false);
								callback();
							},
							success : function(res){
								self.attr('currentSuggestions').replace(res);
								self.attr('isLoading', false);
								callback(res);
							}
						});
					},
					onChange : function(id){
						self.setDisplayName(id);
					}
				});
			};
		}
	}
});
