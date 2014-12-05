steal(
'can/component',
'./sidebar.stache!',
'models',
'./sidebar.less!',
'components/services',
function(Component, initView, Models){

	var KEYMAP = {
		13 : 'ENTER',
		27 : 'ESC'
	};

	return Component.extend({
		tag : 'bh-sidebar',
		template : initView,
		scope : {
			isEditing: false,
			init : function(){
				var self = this;
				if(can.route.attr('hubId')){
					Models.Hub.findOne({
						id: can.route.attr('hubId')
					}).then(function(hub){
						self.attr('hub', hub);
					});
				} else {
					this.attr('hub', new Models.Hub);
				}
			},
			toggleHubEditing : function(){
				var newVal = !this.attr('isEditing');
				newVal && this.attr('hub').backup();
				this.attr('isEditing', newVal);
			},
			restoreOrSave : function(ctx, el, ev){
				var key = KEYMAP[ev.which];

				if(key === 'ENTER'){
					this.attr('hub').attr('name', el.val());
					this.attr('hub').save();
				} else {
					this.attr('hub').restore();
				}

				key && this.attr('isEditing', false);
			}
		},
		events : {
			inserted : 'setPanelHeight',
			'{window} resize' : 'setPanelHeight',
			'{can.route} panel' : function(route, ev, newVal){
				var self = this;
				newVal && setTimeout(function(){
					self.setPanelHeight();
				}, 1);
			},
			setPanelHeight: function(){
				var containerHeight = this.element.height(),
					headerHeight = this.element.find('.header').outerHeight(),
					hubNameHeight = this.element.find('.hub-name-wrap').outerHeight() + 29, // height + margin
					linksHeight = (4 * 37),
					totalHeight = headerHeight + hubNameHeight + linksHeight + 50; // add padding
				this.element.find('.panel-container').height(containerHeight - totalHeight)
			},
			'{scope} isEditing' : function(scope, ev, newVal){
				var self = this;
				if(newVal){
					setTimeout(function(){
						self.element.find('.hub-name').select().focus();
					}, 100);
				}
			}
		},
		helpers : {
			linkToPanel : function(panel){
				panel = can.isFunction(panel) ? panel() : panel;
				return can.route.url({panel: panel}, true);
			},
			isPanel : function(panel, opts){
				panel = can.isFunction(panel) ? panel() : panel;
				return panel === can.route.attr('panel') ? opts.fn(this) : opts.inverse(this);
			}
		}
	});
});
