import can from "can/";
import Bit from "models/bit";
import connectLiveService from "connect-liveservice";
import "can/map/define/";

var addDefaultAttrs = function(params){
	var defaultParams = {
		view: 'public',
		theme: 'light',
		live: false
	};
	return can.extend(defaultParams, params);
};

var liveService;

export default can.Map.extend({
	define : {
		live : {
			set : function(val){
				return (val === true || val === 'true');
			}
		},
		hub : {
			serialize : false,
		},
		bits : {
			Value : Bit.List,
			serialize: false
		},
		currentBrand : {
			serialize: false
		},
		params : {
			serialize: false
		}
	},
	setAttrs : function(attrs){
		this.attr(addDefaultAttrs(attrs));
	},
	init : function(){
		this.setDefaultParams();
	},
	isLive : function(){
		return this.attr('live');
	},
	isPublic : function(){
		return !this.isAdmin();
	},
	showPoweredBy : function(){
		return this.isPublic();
	},
	reset : function(){
		can.batch.start();
		this.setDefaultParams();
		this.bits.splice(0);
		can.batch.stop();
	},
	getView : function(){
		if(this.isAdmin()){
			return 'admin';
		}
		return 'public';
	},
	connectLiveService : function(){

		var hubId = this.attr('hubId');
		liveService = connectLiveService(hubId, this.attr('tenant'));

		if(liveService){
			console.log('LIVESERVICE ENTITIES', liveService);

			liveService.on('entities', can.proxy(Bit.messageFromLiveService, Bit));
		}
	},
	getParams: function(){
		var hubId = this.attr('hubId');
		var params = this.attr('params').attr();
		var tenant = this.attr('tenant');
		var isPublic = this.isPublic();
		var filter = this.attr('filter');

		params.view = this.getView();

		if(isPublic){
			params.tenant_name = tenant;
		} else {
			params.order = this.attr('order') || "created_at:desc";
			if(filter){
				params.show = filter;
			}
		}

		params.hubId = hubId;

		return params;
	},
	setDefaultParams : function(){
		this.attr('params', {
			offset: 0,
			limit: 50
		});
	},
	isAdmin : function(){
		return this.attr('hub') && this.attr('view') === 'admin';
	}
});
