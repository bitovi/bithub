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
			deleteService : function(){
				var deleteItems = this.attr('deleteItems') || false;
				var service = this.attr('service');
				if(deleteItems){
					service.destroyIncludingItems();
				} else {
					service.destroy();
				}
			},
			clearService : function(){
				this.attr('service', null);
			}
		},
		events : {
			'{scope.service} destroyed' : function(){
				if(this.scope.attr('deleteItems')){
					console.log(this.scope.attr('state'))
					this.scope.attr('state').resetEmbed();
				}
				this.scope.clearService();
			}
		}
	})
});