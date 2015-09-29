import can from "can";
import initView from "./moderation.stache!";
import Models from "models/";

import "./moderation.less!";
import "can/map/define/";
import "components/moderation-rules/";

var parseTruthy = function(el){
	return !!parseInt(el.val(), 10);
};

var ModerationVM = can.Map.extend({
	isSaving : false,
	hasErrors: false,
	approveSomeAutomatically: false,
	blockSomeAutomatically: false,
	isModerationOpen : false,
	init : function(){
		var self = this;
		var id = this.attr('appState.currentHub.id');
		Models.Filter.findAll({embed_id: id}, function(filters){
			var blocking = filters.blocking();
			var approving = filters.approving();
			var approveSomeAutomatically = approving.attr('length') > 0;
			var blockSomeAutomatically = blocking.attr('length') > 0;
			self.attr({
				blockingFilters: blocking,
				approvingFilters: approving,
				approveSomeAutomatically: approveSomeAutomatically,
				blockSomeAutomatically: blockSomeAutomatically
			});
		});
	},
	toggleModerationSettings : function(){
		this.attr('isModerationOpen', !this.attr('isModerationOpen'));
	},
	saveHub : function(ctx, el, ev){
		var self = this;
		this.attr({
			hasErrors: false,
			isSaving: true
		});

		$.when(
			this.attr('appState.currentHub').save(),
			this.attr('blockingFilters').saveOrDestroy(),
			this.attr('approvingFilters').saveOrDestroy()
		).then(function(){
			self.attr('isSaving', false);
			self.attr('appState.currentHub').moderate().then(function(){
				self.attr('appState').resetEmbed();
			});
		}, function(){
			self.attr('hasErrors', true);
		});
	},
	
	toggleApprovedByDefault : function(ctx, el){
		this.attr('state.hub.approved_by_default', parseTruthy(el));
	},
	toggleSomeApprovedAutomatically : function(ctx, el){
		this.attr('approveSomeAutomatically', parseTruthy(el));
	},
	toggleSomeBlockedAutomatically : function(ctx, el){
		this.attr('blockSomeAutomatically', parseTruthy(el));
	},
	isApproveSomeAutomatically : function(){
		var hasApproveSomeAutomatically = this.attr('approveSomeAutomatically');
		var hasApprovingFilters = this.attr('approvingFilters.length');
		
		return hasApproveSomeAutomatically || hasApprovingFilters;
	},
	isBlockSomeAutomatically: function(){
		var hasBlockSomeAutomatically = this.attr('blockSomeAutomatically');
		var hasBlockingFilters = this.attr('blockingFilters.length');
		
		return hasBlockSomeAutomatically || hasBlockingFilters;
	}
});

can.Component.extend({
	tag : 'bh-moderation',
	template : initView,
	scope : ModerationVM
});
