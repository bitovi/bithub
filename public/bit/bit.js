steal(
'can/component',
'./bit.stache!',
'lodash/collections/map.js',
'models/bit.js',
'./bit.less!',
'./image-gallery/image-gallery.js',
'./body-wrap/body-wrap.js',
'./share-bit/share-bit.js',
'can/construct/super',
function(Component, initView, _map, Bit){
	
	// check image's status. It's either still loading, loaded or errored
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
		actionFail: null,
		sharePanelOpen: false,
		toggleApproveBit : function(){
			this.attr('bit.is_approved') ? this.disapproveBit() : this.approveBit();
		},
		togglePinBit : function(){
			this.attr('bit.is_pinned') ? this.unpinBit() : this.pinBit();
		},
		actionFailTitle : function(){
			var actionFail = this.attr('actionFail');
			if(actionFail === 'disapprove') return 'block';
			return actionFail;
		},
		removeFailNotice : function(){
			this.attr('actionFail', null);
		},
		showAdminPanel : function(){
			return !!this.attr('state').isAdmin() && !(this.attr('actionFail'));
		},
		sharePanelToggle : function(){
			this.attr('sharePanelOpen', !this.attr('sharePanelOpen'));
		}
	};

	for(var i = 0; i < Bit.ACTIONS.length; i++){
		scope[Bit.ACTIONS[i] + 'Bit'] = (function(action){
			return function(){
				var self = this;
				var def = this.attr('bit')[action](this.attr('state.hubId'));
				def.fail(function(){
					self.attr('actionFail', action);
				})
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
			inserted : function(){

				var self = this;

				this.element.trigger('loading');

				// If this bit wasn't loaded yet add `loading` class
				if(!this.scope.attr('bit').attr('@isLoaded')){
					this.element.addClass('loading');
				}

				// We need to wait until the bit was loaded to calculate it's height
				// When the bit is loaded the `animate-height` class is removed from the bit
				// which will cause the height transition. After the transition is done
				// we remove the explicit height so bit can be resized based on user's actions.
				// If bit was already on the page we don't have to wait for all images to load
				// before removing the height.
				if(!this.scope.attr('bit').attr('@resolvedHeight')){
						this.element.one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', this.proxy('removeExplicitHeight'));
					this.element.addClass('animate-height');
					
				} else {
					this.removeExplicitHeight();
				}

				// When user is admin we want to indicate blocked and pinned items
				if(this.scope.attr('state').isAdmin()){
					if(!this.scope.attr('bit.is_approved')){
						this.element.addClass('blocked');
					} else if(this.scope.attr('bit.is_pinned')){
						this.element.addClass('pinned');
					}
				}
				
				// Wait for all images to load or to error before removing the `loading` class
				this.__initTimeout = setTimeout(function(){
					self.imgs = self.element.find('img').toArray();
					self.imagesToLoadCount = self.imgs.length;

					if(self.imgs.length){
						self.__imgSweeperTimeout = setTimeout(self.proxy('imgSweeper'), 500);
					} else {
						self.doneLoading();
					}
				}, 1);
			},
			'{bit} is_approved' : function(bit, ev, newVal){
				this.scope.attr('state').isAdmin() && this.element.toggleClass('blocked', !newVal);
			},
			'{bit} is_pinned' : function(bit, ev, newVal){
				this.scope.attr('state').isAdmin() && this.element.toggleClass('pinned', newVal);
			},
			'a click' : function(el, ev){
				ev.preventDefault();
				window.open(el.attr('href'));
			},
			// Go through all images and make sure all are loaded or errored
			// Before calling the `doneLoading` function which will remove the loading class
			imgSweeper : function(){
				var statuses = _map(this.imgs, imageStatus);
				var errored;
				
				// If any image is still loading, check again in 500ms
				if(can.inArray('LOADING', statuses) > -1){
					this.__imgSweeperTimeout = setTimeout(this.proxy('imgSweeper'), 500);
				} else {
					this.doneLoading();
				}

				for(var i = 0; i < statuses.length; i++){
					if(statuses[i] === 'ERROR'){
						errored = this.imgs.splice(i, 1)[0];
						errored && $(errored).remove();
					}
				}
			},
			// All images in bit are loaded and we can calculate it's height. We set the explicit height
			// to make sure that that the transition animation runs.
			doneLoading : function(){
				var self = this;

				if(this.element.hasClass('animate-height')){
					this.element.height(this.element.find('.bit').height());
				}

				this.element.removeClass('loading');
				this.element.trigger('loaded');
				this.scope.attr('bit').attr('@isLoaded', true);

			},
			// When we're done with the height transition remove the explicit height
			// and mark the bit's height as resolved
			removeExplicitHeight : function(){
				var self = this;
				setTimeout(function(){
					if(self.element){
						self.element.trigger('bit:loaded');
						self.element.css('height', 'auto');
					}
					self.scope.attr('bit').attr('@resolvedHeight', true);
				}, 1)
				
			},
			// Clean up the timeouts
			destroy : function(){
				clearTimeout(this.__imgSweeperTimeout);
				clearTimeout(this.__initTimeout);
				return this._super.apply(this, arguments);
			}
		}
	})
})
