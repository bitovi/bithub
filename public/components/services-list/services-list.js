steal(
'can/component',
'models',
'./services-list.stache!',
'./services-list.less!',
'can/map/define',
function(Component, Models, initView){

	return Component.extend({
		tag : 'bh-services-list',
		template : initView,
		scope: {
			destroyService: function( service, el, ev) {
				if( confirm('Are you sure?') ) {
					service.destroy();
				}
			},
			editService:function(service){
				this.attr('currentService', service);
			}
		},
		helpers : {
			isCurrentService : function(service, opts){
				service = can.isFunction(service) ? service() : service;
				return service === this.attr('currentService') ? opts.fn(opts.scope.add(service)) : opts.inverse(opts.scope.add(service));
			}
		}
	});
});
