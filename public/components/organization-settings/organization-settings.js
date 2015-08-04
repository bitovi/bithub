import can from "can/";
import initView from "./organization-settings.stache!";

import "./organization-settings.less!";

function validateEmail(email) {
  return email.indexOf('@') > -1;
}

export default can.Component.extend({
	template: initView,
	tag: 'bh-organization-settings',
	scope : {
		inviteUserEmail : "",
		isInviteUserEmailValid : function(){
			return validateEmail(this.attr('inviteUserEmail'));
		},
		setInviteUserEmail : function(ctx, el, ev){
			this.attr('inviteUserEmail', el.val());
		},
		inviteUser: function(){
			var organization = this.attr('state').attr('currentOrganization');
			var self = this;
			organization.invite(this.attr('inviteUserEmail')).then(function(res){
				organization.addInvitation(res);
				self.attr('inviteUserEmail', "");
			}, function(){
				alert("We weren't able to invite the user.");
			});
		}
	}
});
