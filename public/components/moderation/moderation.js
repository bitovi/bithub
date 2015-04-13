steal(
'can/component',
'./moderation.stache!',
'models',
'style',
'./moderation.less!',
'can/map/define',
'components/moderation-rules',
function(Component, initView, Models){

	var parseTruthy = function(el){
		return !!parseInt(el.val(), 10);
	}

	Component.extend({
		tag : 'bh-moderation',
		template : initView,
		scope : {
			isSaving : false,
			hasErrors: false,
			approveSomeAutomatically: false,
			blockSomeAutomatically: false,
			init : function(){
				var self = this;
				Models.Filter.findAll({embed_id: this.attr('hub.id')}, function(filters){
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

				})
			},
			toggleApprovedByDefault : function(ctx, el){
				this.attr('hub.approved_by_default', parseTruthy(el));
			},
			saveHub : function(){
				var self = this;
				this.attr({
					hasErrors: false,
					isSaving: true
				});

				var blockingSave = self.attr('blockingFilters').save();
				var approvingSave = self.attr('approvingFilters').save();
				
				$.when(this.attr('hub').save(), blockingSave, approvingSave).then(function(){
					self.attr('isSaving', false);
					self.attr('state').resetEmbed();
				}, function(){
					self.attr('hasErrors', true);
				})
			},
			toggleSomeApprovedAutomatically : function(ctx, el){
				this.attr('approveSomeAutomatically', parseTruthy(el));
			},
			toggleSomeBlockedAutomatically : function(ctx, el){
				this.attr('blockSomeAutomatically', parseTruthy(el));
			},
			isApproveSomeAutomatically : function(){
				return this.attr('approveSomeAutomatically') || this.attr('approvingFilters.length');
			},
			isBlockSomeAutomatically: function(){
				return this.attr('blockSomeAutomatically') || this.attr('blockingFilters.length');
			}
		},
		events : {
			'form submit' : function(el, ev){
				this.scope.saveHub();
				ev.preventDefault();
			}
		}
	});

})
