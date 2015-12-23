import can from "can";
import initView from "./delete_service_dialog.stache!";
import "./delete_service_dialog.less!";
import "can/construct/proxy/";

export var DeleteServiceDialogVM = can.Map.extend({
	isDeleting : false,
	deleteService : function(){
		var service;
		
		if(this.attr('isDeleting')){
			return;
		}

		service = this.attr('service');

		this.attr('isDeleting', true);
		service.destroy();
	},
	cancelDelete : function(){
		if(this.attr('isDeleting')){
			return;
		}
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
});

can.Component.extend({
	tag: 'bh-delete-service-dialog',
	template: initView,
	scope : DeleteServiceDialogVM,
	events : {
		'{scope.service} destroyed' : function(){
			this.scope.serviceDestroyed();
		}
	}
});
