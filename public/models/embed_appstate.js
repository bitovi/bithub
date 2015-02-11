steal(
'can/map',
'models/bit.js',
'connect-liveservice.js',
'can/map/define', 
function(Map, Bit, connectLiveService){

	var addDefaultAttrs = function(params){
		if(!params.view){
			params.view = 'public';
		}
		return params;
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
			},
			view : {
				set : function(val){
					if(this.isPublic()){
						return 'public';
					}
					return val || 'public';
				}
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
			return !this.attr('hub');
		},
		reset : function(){
			can.batch.start();
			this.setDefaultParams();
			this.bits.splice(0);
			can.batch.stop();
		},
		getParams: function(){
			var hubId = this.attr('hubId');
			var params = this.attr('params').attr();
			var tenant = this.attr('tenant');

			params.view = this.attr('view');

			if(params.view === 'public'){
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
