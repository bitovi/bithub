import can from "can/";
import initView from "./edit_hub_name.stache!";
import "./edit_hub_name.less!";

var KEYMAP = {
	13 : 'ENTER',
	27 : 'ESC'
};

export var EditHubNameVM = can.Map.extend({
	isEditing: false,
	toggleHubEditing : function(val){
		val = (typeof val === 'undefined') ? !this.attr('isEditing') : val;
		this.attr('isEditing', val);
	},
	commitNewHubName : function(val){
		var hub = this.attr('hub');
		var name = hub.attr('name');
		if(name !== val){
			hub.attr('name', val);
			hub.save();
		}
	}
});

can.Component.extend({
	tag: 'bh-edit-hub-name',
	template: initView,
	scope: EditHubNameVM,
	events : {
		'{scope} isEditing' : function(scope, ev, newVal){
			var self = this;
			if(newVal){
				setTimeout(function(){
					if(self.element){
						self.element.find('.hub-name').select().focus();
					}
				}, 100);
			}
		},
		click : function(){
			this.scope.toggleHubEditing();
		},
		"input click" : function(el, ev){
			ev.stopImmediatePropagation();
		},
		"input keyup" : function(el, ev){
			var key = KEYMAP[ev.which];
			if(key === 'ENTER'){
				this.scope.commitNewHubName(el.val());
			}
			if(key){
				this.__preventBlur = true;
				this.scope.toggleHubEditing();
			}
		},
		"input blur" : function(el, ev){
			if(this.__preventBlur){
				delete this.__preventBlur;
			} else {
				this.scope.commitNewHubName(el.val());
				this.scope.toggleHubEditing();
			}
		}
	}
});
