import can from "can";
import "can/map/define/";

export default can.Model.extend({}, {
	define : {
		operation : {
			set : function(val){
				var typeAndOp = val.split(":");
				var type = typeAndOp.shift();
				var op = typeAndOp.shift();
				
				this.attr({
					is_negated: (type !== 'pos'),
					op : op
				});
			},
			get : function(){
				var type = this.attr('is_negated') ? 'neg' : 'pos';
				var op = this.attr('op');
				return [type, op].join(':');
			}
		},
		attr_name : {
			value : 'content'
		},
		op : {
			value : 'contains_all',
			set : function(val){
				return val;
			}
		},
		is_negated : {
			value : false
		}
	}
});
