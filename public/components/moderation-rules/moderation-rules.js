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
			markToDestroy : function(filter, el, ev){
				ev.preventDefault();
				filter.markToDestroy();
			},
			title : function(){
				return TITLES[this.attr('filters.action')];
			},
			filtersNotMarkedForDelete : function(){
				var filters = this.attr('filters');
				filters.attr('length');
				return can.grep(filters, function(f){
					return !f.attr('__shouldDelete');
				});
			}
		},
		events : {
			"[can-click=addFilter],[can-click=removeFilter] click" : function(el, ev){
				ev.preventDefault();
			}
		}
	});
});
