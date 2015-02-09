steal(
'can/component',
'./bit.stache!',
'./bit.less!',
'components/image-gallery',
'components/body-wrap',
function(Component, initView){
	return Component.extend({
		tag: 'bh-bit',
		template : initView,
		events : {

		},
		helpers : {
			formattedTitle : function(title){
				title = can.isFunction(title) ? title() : title;
				if(title && title !== 'undefined'){
					return title;
				}
				return "";
			}
		},
		events : {
			init : function(){
				var self = this;
				
				this.element.addClass('loading')
				this.imagesToLoadCount = 0;

				setTimeout(function(){
					var imgs = self.element.find('img');

					self.imagesToLoadCount = imgs.length;

					if(imgs.length){
						
						imgs.each(function(){
							var $img = $(this);
							$img.one('load', self.proxy('imageDone'));
							$img.one('error', self.proxy('imageErrored'));
						});
					} else {
						self.updateVisibility();
					}
				});
			},
			updateVisibility : function(){
				if(this.imagesToLoadCount === 0){
					this.element.removeClass('loading');
				}
			},
			imageDone : function(){
				this.imagesToLoadCount--;
				this.updateVisibility();
			},
			imageErrored : function(ev){
				$(ev.target).remove();
				this.imageLoaded();
			}
		}
	})
})