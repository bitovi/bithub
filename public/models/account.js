import can from "can/";
import Organization from "./organization";

import "can/map/define/";

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
	}
});
