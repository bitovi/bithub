import can from "can/";
import ServiceModel from './service';
import 'can/list/promise/';
import 'can/construct/super/';
import 'can/map/backup/';
import 'can/map/define/';

export default can.Model.extend({
	resource : '/api/v3/embeds',
}, {
	define : {
		services : {
			get : function(){
				return new ServiceModel.List({embed_id: this.attr('id')});
			}
		}
	},
	serialize : function(){
		return {
			embed : this._super.apply(this, arguments)
		};
	},
	moderate : function(){
		return $.ajax({
			type : 'POST',
			url : '/api/v3/embeds/' + this.attr('id') + '/moderate'
		});
	}
});
