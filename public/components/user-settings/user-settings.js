import can from "can/";
import initView from "./user-settings.stache!";

import "./user-settings.less!";



export default can.Component.extend({
	template: initView,
	tag: 'bh-user-settings',
	scope : {
		updateAccount : function(ctx, el, ev){
			var account = this.attr('state').attr('currentAccount');
			var self = this;

			this.removeAttr('notice');
			this.removeAttr('errors');

			account.save(function(){
				self.attr('notice', 'Your credentials were saved');
			}, function(res){
				self.attr('errors', res.responseJSON.errors);
			});
			ev.preventDefault();
		}
	}
});
