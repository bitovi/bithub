import can from "can";
import "can/list/promise/";

var EntityDecision = can.Model.extend({
	findAll : '/api/v4/embeds/{hubId}/entities/stats'
}, {
	dec: function(){
		this.attr('count', this.attr('count') - 1);
	},
	inc: function(){
		this.attr('count', this.attr('count') + 1);
	}
});

EntityDecision.List = EntityDecision.List.extend({
	getById : function(id){
		var length = this.attr('length');
		for(var i = 0; i < length; i++){
			if(this[i].id === id){
				return this[i];
			}
		}
	}
});

export default EntityDecision;
