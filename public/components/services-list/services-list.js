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
			init : function(){
				this.attr('shownErrors', []);
			},
			destroyService: function( service, el, ev) {
				if( confirm('Are you sure?') ) {
					service.destroy();
				}
			},
			editService:function(service){
				this.attr('currentService', service);
			},
			toggleErrorShowing : function(service){
				var shownErrors = this.attr('shownErrors'),
					index = shownErrors.indexOf(service);
				if(index > -1){
					shownErrors.splice(index, 1);
				} else {
					shownErrors.push(service);
				}
			}
		},
		helpers : {
			isCurrentService : function(service, opts){
				service = can.isFunction(service) ? service() : service;
				return service === this.attr('currentService') ? opts.fn(opts.scope.add(service)) : opts.inverse(opts.scope.add(service));
			},
			showErrorsForService : function(service, opts){
				service = can.isFunction(service) ? service() : service;
				if(this.attr('shownErrors').indexOf(service) > -1 && service.attr('error')){
					return opts.fn();
				}
			}
		}
	});
});
