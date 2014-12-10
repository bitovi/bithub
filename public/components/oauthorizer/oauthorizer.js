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
			isAuthorized : false,
			isAuthorizing : false,
			oauthorize : function(){
				var self = this,
					service = this.attr('service');

				if(!service){
					throw "You must initialize bh-oauthorizer component with the `service` attribute";
				}

				this.attr('isAuthorizing', true);

				OAuthConnect(service).then(function(){
					Models.Identity.reloadAll().then(function(identities){
						self.attr({
							identities : identities,
							isAuthorizing : false,
							isAuthorized : identities.hasIdentityForService(service)
						});
					});
				});
			}
		}
	})
});