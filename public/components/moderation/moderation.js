steal(
'can/component',
'./moderation.stache!',
'models',
'style',
'./moderation.less!',
'can/map/define',
function(Component, initView, Models){

	Component.extend({
		tag : 'bh-moderation',
		template : initView,
		scope : {
			isSaving : false,
			hasErrors: false,
			toggleApprovedByDefault : function(ctx, el){
				var value = parseInt(el.val(), 10);
				this.attr('hub.approved_by_default', value === 1);
			},
			saveHub : function(){
				var self = this;
				this.attr({
					hasErrors: false,
					isSaving: true
				});

				this.attr('hub').save(function(){
					self.attr('isSaving', false);
					self.attr('state').resetEmbed();
				}, function(){
					self.attr('hasErrors', true);
				});
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