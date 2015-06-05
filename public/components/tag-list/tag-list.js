import can from "can/";
import initView from "./tag-list.stache!";
import "./tag-list.less!";

var KEYMAP = {
	COMMA : 188,
	SPACE : 32,
	BACKSPACE : 8,
	ENTER : 13
};

export var TagListVM = can.Map.extend({
	init : function(){
		if(!this.attr('tags')){
			this.attr('tags', []);
		}
	},
	removeTag : function(tag){
		var tags  = this.attr('tags');
		var index = tag ? tags.indexOf(tag) : tags.attr('length') - 1;
		if(index >= 0){
			tags.splice(index, 1);
		}
	},
	addTag : function(tag){
		var tags, canAddTag;
		
		tag = tag.replace(/[^a-zA-Z0-9-_]/g ,"");
		tags = this.attr('tags');
		canAddTag = tags.indexOf(tag) === -1;

		if(canAddTag){
			tags.push(tag);
		}
	}
});

can.Component.extend({
	tag : 'bh-tag-list',
	template : initView,
	scope : TagListVM,
	events: {
		'input keydown' : function(el, ev){
			var val = can.trim(el.val());
			if((ev.which === KEYMAP.COMMA ||
					ev.which === KEYMAP.SPACE ||
					ev.which === KEYMAP.ENTER) && val !== ''){
				this.scope.addTag(val);
				el.val('');
				if(ev.which !== KEYMAP.ENTER){
					ev.preventDefault();
				}
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
		'input blur' : function(el, ev){
			var val = can.trim(el.val() || "");
			if(val !== ""){
				this.scope.addTag(val);
				el.val("");
			}
		},
		click : function(el, ev){
			if(ev.target === this.element[0] || $(ev.target).is('.tag-list-wrap')){
				this.element.find('input').focus();
			}
		}
	}
});
