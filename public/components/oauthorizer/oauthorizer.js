steal(
'can/component',
'./oauthorizer.stache!',
'models',
'./oauthorizer.less!',
'can/map/define',
function(Component, initView, Models){


	var OAuthConnect = function(feed) {
		var windowPropsStr     = "width=600,height=300,scrollbars=yes",
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
			define : {
				identities : {
					get : function(){
						return Models.Identity.getAll();
					}
				}
			},
			isAuthorized : function(){
				return this.attr('identities').hasIdentityForService(this.attr('feed'));
			},
			isAuthorizing : false,
			oauthorize : function(){
				var self = this,
					feed = this.attr('feed');

				if(!feed){
					throw "You must initialize bh-oauthorizer component with the `feed` attribute";
				}

				this.attr('isAuthorizing', true);

				OAuthConnect(feed).then(function(){
					Models.Identity.reloadAll().then(function(identities){
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