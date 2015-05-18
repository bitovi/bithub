steal(
	'can/component',
	'./share-bit.stache!',
	'./share-bit.less!',
	function(Component, initView){
		var popup = {
			googleplus: function(opt){	window.open("https://plus.google.com/share?hl=en&url="+encodeURIComponent(opt.url), "", "toolbar=0, status=0, width=900, height=500");
			},
			facebook: function(opt){
				window.open("http://www.facebook.com/sharer/sharer.php?u="+encodeURIComponent(opt.url)+"&t="+opt.title+"", "", "toolbar=0, status=0, width=900, height=500");
			},
			twitter: function(opt){	window.open("https://twitter.com/intent/tweet?text="+encodeURIComponent(opt.title)+"&url="+encodeURIComponent(opt.url)+'&via='+opt.via, "", "toolbar=0, status=0, width=650, height=360");
			},
			delicious: function(opt){	window.open('http://www.delicious.com/save?v=5&noui&jump=close&url='+encodeURIComponent(opt.url)+'&title='+opt.title, 'delicious', 'toolbar=no,width=550,height=550');
			},
			stumbleupon: function(opt){
				window.open('http://www.stumbleupon.com/badge/?url='+encodeURIComponent(opt.url), 'stumbleupon', 'toolbar=no,width=550,height=550');
			},
			linkedin: function(opt){
				window.open('https://www.linkedin.com/cws/share?url='+encodeURIComponent(opt.url)+'&token=&isFramed=true', 'linkedin', 'toolbar=no,width=550,height=550');
			},
			pinterest: function(opt){
			window.open('http://pinterest.com/pin/create/button/?url='+encodeURIComponent(opt.url)+'&media='+encodeURIComponent(opt.media)+'&description='+opt.title, 'pinterest', 'toolbar=no,width=700,height=300');
			}
		};
		return Component.extend({
			template: initView,
			tag: 'bh-share-bit',
			scope : {
				networksClass : function(){
					return this.media ? 'networks-7' : 'networks-6';
				}
			},
			events: {
				"[data-network] click" : function(el, ev){
					var network = el.data('network');
					var el = document.createElement('div');
					el.innerHTML = this.scope.cardTitle;

					var title = el.innerText;

					if(network === 'pinterest' || network === 'delicious'){
						title = title.replace(/#/g, '');
					}

					popup[network]({
						title: title,
						media: this.scope.media,
						url: this.scope.url,
						via : "bithubapp"
					})
				}
			}
		})
	});
