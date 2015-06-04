import can from "can/";
import initView from "./sidebar.stache!";

import './sidebar.less!';
import 'components/services/';
import 'components/moderation/';
import 'components/embed_publish/';
import 'components/edit_hub_name/';
import 'can/route/';
import 'components/helpers';

can.Component.extend({
	tag : 'bh-sidebar',
	template : initView,
	scope : {
		init : function(){
			console.log(this.attr())
},
		menuOpen : true,
		toggleSidebarPosition : function(ctx, el, ev){
			this.attr('state.sidebarIsExpanded', !this.attr('state.sidebarIsExpanded'));
		},
		toggleSidebar : function(val){
			this.attr('menuOpen', val);
		}
	},
	events : {
		init : function(){
			this.element.on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', this.proxy('toggleMenu'));
		},
		toggleMenu : function(){
			this.scope.toggleSidebar(this.scope.attr('state.sidebarIsExpanded'));
		},
		'{state} sidebarIsExpanded' : function(state, ev, newVal){
			if(newVal){
				this.scope.toggleSidebar(true);
			}
		}
	},
	helpers : {
		linkToPanel : function(panel){
			panel = can.isFunction(panel) ? panel() : panel;
			return can.route.url({panel: panel}, true);
		}
	}
});
