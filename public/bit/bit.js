steal(
'can/component',
'./bit.stache!',
'lodash/collections/map.js',
'models/bit.js',
'./bit.less!',
'components/image-gallery',
'components/body-wrap',
function(Component, initView, _map, Bit){

	var imageStatus = function(img){
		if(!img.complete){
			return 'LOADING';
		}
		if(img.naturalWidth === 0){
			return 'ERROR';
		}
		return 'LOADED';
	}

	var scope = {
		toggleApproveBit : function(){
			this.attr('bit.is_approved') ? this.disapproveBit() : this.approveBit();
		},
		togglePinBit : function(){
			this.attr('bit.is_pinned') ? this.unpinBit() : this.pinBit();
		}
	};

	for(var i = 0; i < Bit.ACTIONS.length; i++){
		scope[Bit.ACTIONS[i] + 'Bit'] = (function(action){
			return function(){
				this.attr('bit')[action](this.attr('state.hubId'));
			}
		})(Bit.ACTIONS[i]);
	}

	return Component.extend({
		tag: 'bh-bit',
		template : initView,
		scope : scope,
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
				
				this.element.addClass('loading');
				this.element.trigger('loading');

				!this.scope.attr('is_approved') && this.element.addClass('blocked');

				setTimeout(function(){
					self.imgs = self.element.find('img').toArray();
					self.imagesToLoadCount = self.imgs.length;

					if(self.imgs.length){
						setTimeout(self.proxy('imgSweeper'), 500);
					} else {
						self.updateVisibility();
					}
				}, 1);
			},
			'{bit} is_approved' : function(bit, ev, newVal){
				this.element.toggleClass('blocked', !newVal)
			},
			imgSweeper : function(){
				var statuses = _map(this.imgs, imageStatus);
				var errored;

				if(can.inArray('LOADING', statuses) > -1){
					setTimeout(this.proxy('imgSweeper'), 500);
				} else {
					this.updateVisibility();
				}

				for(var i = 0; i < statuses.length; i++){
					if(statuses[i] === 'ERROR'){
						errored = this.imgs.splice(i, 1)[0];
						errored && $(errored).remove();
					}
				}
			},
			updateVisibility : function(){
				var self = this;
				this.element.height(this.element.find('.bit').height() - 3);
				this.element.removeClass('loading');
				this.element.trigger('loaded');
				setTimeout(function(){
					self.element && self.element.css('height', 'auto');
				}, 400);
			}
		}
	})
})