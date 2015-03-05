steal(
'can/component',
'./delete-service-dialog.stache!',
'./delete-service-dialog.less!',
'can/construct/proxy',
function(Component, initView){
	return Component.extend({
		tag: 'bh-delete-service-dialog',
		template: initView,
		scope : {
			isDeleting : false,
			deleteService : function(){
				if(this.attr('isDeleting')) return;
				var service = this.attr('service');

				this.attr('isDeleting', true);
				service.destroy();
			},
			cancelDelete : function(){
				if(this.attr('isDeleting')) return;
				this.clearService();
			},
			clearService : function(){
				this.attr('service', null);
			},
			serviceDestroyed : function(){
				can.batch.start();
				this.attr('state').resetEmbed();
				this.attr('isDeleting', false);
				this.clearService();
				can.batch.stop();
			}
		},
		events : {
			'{scope.service} destroyed' : function(){
				this.scope.serviceDestroyed();
			}
		}
	})
});