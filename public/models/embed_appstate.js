steal(
'can/map',
'models/bit.js',
'connect-liveservice.js',
'can/map/define', 
function(Map, Bit, connectLiveService){

	var addDefaultAttrs = function(params){
		var defaultParams = {
			view: 'public',
			theme: 'light',
			live: false
		}
		return can.extend(defaultParams, params);
	}

	var liveService;



	return Map.extend({
		define : {
			hubId : {
				set : function(val){
					var tenant = this.isPublic() ? this.attr('tenant') : null;
					liveService = connectLiveService(val, tenant);
					if(liveService){
						liveService.on('entities', can.proxy(Bit.messageFromLiveService, Bit));
					}
					return val;
				}
			},
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
			console.log('SET ATTRS', attrs, addDefaultAttrs(attrs))
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
		getParams: function(){
			var hubId = this.attr('hubId');
			var params = this.attr('params').attr();
			var tenant = this.attr('tenant');
			var isPublic = this.isPublic();

			params.view = this.getView();

			if(isPublic){
				params.tenant_name = tenant;
			} else {
				params.order = "created_at:desc"
			}

			params.hubId = hubId;

			return params;
		},
		setDefaultParams : function(){
			this.attr('params', {
				offset: 0,
				limit: 15
			});
		},
		isAdmin : function(){
			return this.attr('hub') && this.attr('view') === 'admin';
		}
	});
});
