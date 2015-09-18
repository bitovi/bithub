import can from "can/";

export default can.Model.extend({
	findOne : '/api/v3/current/organization',
	update: 'PUT /api/v3/current/organization',
	current : function(){
		return this.findOne({});
	},
	choose : function(id){
		return $.ajax({
			url: '/api/v3/current/organization/choose?id=' + id,
			type: 'PUT'
		});
	}
}, {
	invite : function(email){
		var def = can.Deferred();
		$.post('/api/v3/current/organization/accounts', {account: {email: email}}).then(function(res){
			def.resolve(res.account);
		}, function(){
			$.post('/accounts/invitation', {account: {email: email}}).then(function(res){
				def.resolve(res);
			}, function(){
				def.reject();
			});
		});
		return def;
	},
	addInvitation: function(invitation){
		if(!this.attr('invitations')){
			this.attr('invitations', []);
		}
		this.attr('invitations').push(invitation);
	}
});
