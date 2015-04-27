steal(
	'can/component',
	'./facebook-public-page.stache!',
	'./facebook-public-page.less!',
	'components/suggestions',
	function(Component, initView){

		var getPageName = function(url){
			var a = document.createElement('a');
			var pathname;

			a.href = url;
			pathname = a.pathname;
			return pathname.replace('facebook.com', '').replace(/^\/+/, '');
		}


		return Component.extend({
			tag : 'bh-facebook-public-page-service',
			template : initView,
			scope : {
				loading: "",
				loadedPage: null,
				error: "",
				init : function(){
										
				},
				loadPage : function(ctx, el, ev){
					ev.preventDefault();

					var url = getPageName(this.attr('pageUrl'));
					var self = this;
					can.batch.start();
					this.attr({
						loading:  "http://facebook.com/<b>" + url + "</b>",
						error : "",
						loadedPage: null
					});
					this.attr('map.config', {});
					can.batch.stop();
					$.get("http://graph.facebook.com/" + url).then(function(result){
						can.batch.start();
						self.attr({
							loadedPage: result,
							loading: ""
						});
						self.attr('map.config', {
							id: result.id,
							display_name: result.name
						});
						can.batch.stop();
					}, function(){
						self.attr({
							error: "We can't load the page. Please check the URL",
							loading: "",
							loadedPage: null
						});
					});
				}
			},
			events : {
				inserted : function(){
					this.disableSave();
				},
				"{scope} loadedPage" : function(ev, scope, val){
					if(val === null){
						this.disableSave();
					} else {
						this.enableSave();
					}	
				},
				disableSave : function(){
					this.element.trigger('service:saveDisabled');
				},
				enableSave : function(){
					this.element.trigger('service:saveEnabled');
				}
			}
		});
	});
