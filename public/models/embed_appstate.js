steal(
'can/map',
'models/bit.js',
'can/map/define', 
function(Map, Bit){

	return Map.extend({
		define : {
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
		init : function(){
			this.setDefaultParams();
		},
		getParams: function(){
			var hubId = this.attr('hubId');
			var params = this.attr('params').attr();
			var tenant = this.attr('tenant');

			if(!this.isAdmin()){
				params.tenant_name = tenant;
				params.order = "thread_updated_ts:desc"
			}

			params.view = this.isAdmin() ? 'admin' : 'public';
			params.hubId = hubId;

			return params;
		},
		setDefaultParams : function(){
			this.attr('params', {
				offset: 0,
				limit: 15,
				order: "created_at:desc"
			});
		},
		isAdmin : function(){
			return !!this.attr('hub');
		}
	});
});
