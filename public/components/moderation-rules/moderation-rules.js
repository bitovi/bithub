steal(
'can/component',
'./moderation-rules.stache!',
'models',
'./moderation-rules.less!',
function(Component, initView, Models){
	
	var TITLES = {
		approve : "<b>Automatically approve items</b> matching the following rules:",
		block   : "<b>Automatically block items</b> matching the following rules"
	}

	return Component.extend({
		tag : 'bh-moderation-rules',
		template : initView,
		scope: {
			addFilter : function(){
				this.attr('filters').addFilter(this.attr('hub.id'));
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
			},
		},
		events : {
			"[can-click=addFilter],[can-click=markToDestroy] click" : function(el, ev){
				ev.preventDefault();
			}
		},
		helpers : {
				isContainsFilter : function(query, opts){
					var check;
					query = can.isFunction(query) ? query() : query;
					check =  query.attr('op') === 'contains_any' || query.attr('op') === 'contains_all';
					return check ? opts.fn() : opts.inverse();
				}
		}
	});
});
