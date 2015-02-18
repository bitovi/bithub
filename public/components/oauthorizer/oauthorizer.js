steal(
'can/component',
'./oauthorizer.stache!',
'models',
'./oauthorizer.less!',
'can/map/define',
function(Component, initView, Models){


	var OAuthConnect = function(feed) {
		var windowPropsStr     = "width=800,height=600,scrollbars=yes",
			title              = "OAuth Login",
			host               = window.location.host.split('.'),
			url                = '/auth/' + feed,
			oauthWindow        = window.open(url, title, windowPropsStr),
			def                = can.Deferred(),
			oauthWindowSweeper = window.setInterval(function() {
				if (oauthWindow.closed) {
					clearInterval(oauthWindowSweeper);
					def.resolve();
				}
			}, 100);
		return def;
	}



	return Component.extend({
		tag : 'bh-oauthorizer',
		template : initView,
		scope : {
			init : function(){
				var self = this;
				Models.Identity.findAll({}).then(function(identities){
					self.attr('identities', identities);
				});
			},
			isAuthorized : function(){
				return this.hasIdentityForService(this.attr('feed'));
			},
			hasIdentityForService : function(service){
				var identities = this.attr('identities'),
					length = identities.attr('length');

				for(var i = 0; i < length; i++){
					if(identities.attr(i + '.provider') === service){
						return true;
					}
				}
				return false;
			},
			identities: null,
			isAuthorizing : false,
			isPending : function(){
				return this.attr('identities') === null;
			},
			oauthorize : function(ctx, el, ev){
				var self = this,
					feed = this.attr('feed');

				if(!feed){
					throw "You must initialize bh-oauthorizer component with the `feed` attribute";
				}

				this.attr('isAuthorizing', true);

				OAuthConnect(feed).then(function(){
					Models.Identity.findAll({}).then(function(identities){
						console.log(identities)
						self.attr({
							identities : identities,
							isAuthorizing : false
						});
					});
				});
			}
		}
	})
});