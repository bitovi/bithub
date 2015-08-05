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
				can.batch.start();
				self.attr('notice', 'Your credentials were saved');
				account.removeAttr('current_password');
				account.removeAttr('password');
				account.removeAttr('password_confirmation');
				can.batch.stop();
			}, function(res){
				self.attr('errors', res.responseJSON.errors);
			});
			ev.preventDefault();
		}
	}
});
