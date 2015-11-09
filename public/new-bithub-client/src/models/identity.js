import can from "can";
import "can/list/promise/";

var identities;

export default can.Model.extend({
	resource : '/api/v3/identities',
	getAll : function(){
		return this.reloadAll();
	},
	reloadAll : function(){
		var def = new this.List({});

		def.then(function(data){
			identities = data;
		});

		return def;
	}
}, {});
