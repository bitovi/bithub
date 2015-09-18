import can from "can";
import initView from "./services-list.stache!";
import "./services-list.less!";
import "can/map/define/";
import "components/delete_service_dialog/";
import "components/service-config-formatter/";

can.Component.extend({
	tag : 'bh-services-list',
	template : initView,
	scope: {
		deletingService: null,
		init : function(){
			this.attr({
				shownErrors: [],
				hiddenNoResults: []
			});
		},
		hideNoResults : function(service){
			this.attr('hiddenNoResults').push(service);
		},
		destroyService: function( service, el, ev) {
			this.attr('deletingService', service);
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
			var check;

			service = can.isFunction(service) ? service() : service;
			
			check = service === this.attr('currentService');
			check = check && !service.isNew();

			return check ? opts.fn(opts.scope.add(service)) : opts.inverse(opts.scope.add(service));
		},
		isServiceCurrentlyLoading : function(service, opts){
			var currentlyLoading = this.attr('state.loadingServices');

			service = can.isFunction(service) ? service() : service;
			
			if(service.isLoading() || (currentlyLoading.indexOf(service) !== -1 && !service.attr('error') && !service.attr('noResults'))){
				return opts.fn();
			}
		},
		serviceHasNoResults : function(service, opts){
			service = can.isFunction(service) ? service() : service;
			this.attr('hiddenNoResults').attr('length');
			if(service.attr('noResults') && this.attr('hiddenNoResults').indexOf(service) === -1){
				return opts.fn();
			}
		},
		showErrorsForService : function(service, opts){
			service = can.isFunction(service) ? service() : service;
			this.attr('shownErrors').attr('length');
			if(service.attr('error') && this.attr('shownErrors').indexOf(service) !== -1){
				return opts.fn();
			}
		}
	},
	events : {
		'{currentService} created' : function(){
			this.scope.attr('currentService', null);
		}
	}
});
