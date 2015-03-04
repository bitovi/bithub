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
				var deleteItems = this.attr('deleteItems') || false;
				var service = this.attr('service');

				this.attr('isDeleting', true);
				if(deleteItems){
					service.destroyIncludingItems();
				} else {
					service.destroy();
				}
			},
			cancelDelete : function(){
				if(this.attr('isDeleting')) return;
				this.clearService();
			},
			clearService : function(){
				this.attr('service', null);
			}
		},
		events : {
			'{scope.service} destroyed' : function(){
				if(this.scope.attr('deleteItems')){
					this.scope.attr('state').resetEmbed();
				}
				this.scope.attr('isDeleting', false);
				this.scope.clearService();
			}
		}
	})
});