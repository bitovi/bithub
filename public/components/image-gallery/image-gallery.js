steal(
'can/component',
'./image-gallery.stache!',
'./image-gallery.less!', function(Component, initView){
	return Component.extend({
		tag: 'bh-image-gallery',
		template: initView,
		scope: {
			init : function(){
				console.log(this.attr('images'))
				this.attr('currentImage', this.attr('images.0'));
			},
			setCurrent : function(img){
				this.attr('currentImage', img);
			},
			hasGallery : function(){
				return this.attr('images').attr('length') > 1;
			}
		},
		helpers : {
			isCurrent : function(img, opts){
				img = can.isFunction(img) ? img() : img;
				if(img === this.attr('currentImage')){
					return opts.fn();
				}
			}
		}
	})
});