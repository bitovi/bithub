steal(
'can/component',
'./sidebar.stache!',
'models',
'./sidebar.less!',
'components/services',
'components/moderation',
'components/integration',
'can/route',
'components/helpers.js',
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
				
				if(this.attr('state.hubId')){
					Models.Hub.findOne({
						id: this.attr('state.hubId')
					}).then(function(hub){
						self.attr('hub', hub);
					});
				} else {
					throw "No Hub selected";
				}
			},
			toggleHubEditing : function(ctx, el, ev){
				var newVal = !this.attr('isEditing');
				newVal && this.attr('hub').backup();
				this.attr('isEditing', newVal);
				ev.stopPropagation();
			},
			preventHubEditingToggle : function(ctx, el, ev){
				ev.stopPropagation();
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
			},
			toggleSidebarPosition : function(ctx, el, ev){
				this.attr('state.sidebarIsExpanded', !this.attr('state.sidebarIsExpanded'));
			}
		},
		events : {
			'{scope} isEditing' : function(scope, ev, newVal){
				var self = this;
				if(newVal){
					setTimeout(function(){
						self.element && self.element.find('.hub-name').select().focus();
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
				return panel === this.attr('state.panel') ? opts.fn(this) : opts.inverse(this);
			}
		}
	});
});
