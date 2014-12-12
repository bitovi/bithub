steal(
'can/component',
'./tag-list.stache!',
'./tag-list.less!',
function(Component, initView){

	var KEYMAP = {
		COMMA : 188,
		SPACE : 32,
		BACKSPACE : 8
	}

	return Component.extend({
		tag : 'bh-tag-list',
		template : initView,
		scope : {
			init : function(){
				if(!this.attr('tags')){
					this.attr('tags', []);
				}
			},
			removeTag : function(tag){
				var tags  = this.attr('tags'),
					index = tag ? tags.indexOf(tag) : tags.attr('length') -1;
				index >= 0 && tags.splice(index, 1);
			},
			addTag : function(tag){
				var tags = this.attr('tags'),
					canAddTag = tags.indexOf(tag) === -1;
				if(canAddTag){
					tags.push(tag);
				}
			}
		},
		events: {
			'input keydown' : function(el, ev){
				var val = can.trim(el.val());
				if((ev.which === KEYMAP.COMMA || ev.which === KEYMAP.SPACE) && val !== ''){
					this.scope.addTag(val);
					el.val('');
					ev.preventDefault();
				} else if(ev.which === KEYMAP.BACKSPACE && this.__lastSelectionStart === 0){
					this.scope.removeTag();
				}
				this.__lastSelectionStart = el[0].selectionStart;
			},
			'input click': function(el){
				this.__lastSelectionStart = el[0].selectionStart;
			},
			'input focus': function(el){
				this.__lastSelectionStart = el[0].selectionStart;
			},
			click : function(el, ev){
				if(ev.target === this.element[0] || $(ev.target).is('.tag-list-wrap')){
					this.element.find('input').focus();
				}
			}
		}
	})
});