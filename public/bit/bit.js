steal(
'can/component',
'./bit.stache!',
'lodash/collections/map.js',
'models/bit.js',
'./bit.less!',
'components/image-gallery',
'components/body-wrap',
'components/share-bit',
'can/construct/super',
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

				if(!this.scope.attr('bit').attr('@isLoaded')){
					this.element.addClass('loading');
				}

				

				if(!this.scope.attr('bit').attr('@hasHeight')){
					this.element.one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', this.proxy('removeExplicitHeight'));
				this.element.addClass('animate-height');
					
				} else {
					this.removeExplicitHeight();
				}

				if(this.scope.attr('state').isAdmin()){
					if(!this.scope.attr('bit.is_approved')){
						this.element.addClass('blocked');
					} else if(this.scope.attr('bit.is_pinned')){
						this.element.addClass('pinned');
					}
				}

				this.__initTimeout = setTimeout(function(){
					self.imgs = self.element.find('img').toArray();
					self.imagesToLoadCount = self.imgs.length;

					if(self.imgs.length){
						self.__imgSweeperTimeout = setTimeout(self.proxy('imgSweeper'), 500);
					} else {
						self.updateVisibility();
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
			imgSweeper : function(){
				var statuses = _map(this.imgs, imageStatus);
				var errored;

				if(can.inArray('LOADING', statuses) > -1){
					this.__imgSweeperTimeout = setTimeout(this.proxy('imgSweeper'), 500);
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
				

				if(this.element.hasClass('animate-height')){
					this.element.height(this.element.find('.bit').height());
				}

				this.element.removeClass('loading');

				this.element.trigger('loaded');

				this.scope.attr('bit').attr('@isLoaded', true);

			},
			removeExplicitHeight : function(){
				var self = this;
				setTimeout(function(){
					//self.element.removeClass('animate-height').css('height', 'auto');
					self.element.trigger('bit:loaded');				
					self.scope.attr('bit').attr('@hasHeight', true);
				}, 1)
				
			},
			destroy : function(){
				clearTimeout(this.__imgSweeperTimeout);
				clearTimeout(this.__initTimeout);
				return this._super.apply(this, arguments);
			}
		}
	})
})
