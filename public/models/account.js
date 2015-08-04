import can from "can/";
import Organization from "./organization";

import "can/map/define/";
import "can/construct/super/";

export default can.Model.extend({
	findOne : '/api/v3/current/account',
	update: 'PUT /api/v3/current/account',
	current : function(){
		return this.findOne({});
	}
}, {
	define : {

		organizations : {
			Type : Organization.List
		}
	},
	serialize: function() {
		var data = this._super();
		
		if(data.password && !data.password_confirmation){
			data.password_confirmation = "";
		}

		return { account: data };
	}
});
