import can from "can/";
export default can.Model.extend({
	findOne : '/api/v3/accounts/{id}',
	current : function(){
		return this.findOne({id: 'current'});
	}
}, {});
