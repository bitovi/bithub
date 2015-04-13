steal(
'can/component',
'./moderation-rules.stache!',
'models',
'./moderation-rules.less!',
function(Component, initView, Models){
	
	var TITLES = {
		approve : "Approving Filters",
		block   : "Blocking Filters"
	}

	return Component.extend({
		tag : 'bh-moderation-rules',
		template : initView,
		scope: {
			addFilter : function(){
				this.attr('filters').addFilter(this.attr('hub.id'));
			},
			removeFilter : function(filter, el, ev){
				ev.preventDefault();
				filter.destroy();
			},
			title : function(){
				return TITLES[this.attr('filters.action')];
			}
		},
		events : {
			"[can-click=addFilter],[can-click=removeFilter] click" : function(el, ev){
				ev.preventDefault();
			}
		}
	});
});
