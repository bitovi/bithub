import can from "can/";
import initView from "./user-settings.stache!";

import "./user-settings.less!";



export default can.Component.extend({
	template: initView,
	tag: 'bh-user-settings',
	scope : {
		updateAccount : function(ctx, el, ev){
			var account = this.attr('state').attr('currentAccount');
			account.save();
			ev.preventDefault();
		}
	}
});
