import can from "can/";
import initView from "./bit.stache!";
import _map from "lodash/collections/map";

import "./image-gallery/image-gallery";
import "./body-wrap/body-wrap";
import "./share-bit/share-bit";

import "./bit.less!";
import "can/construct/super/super";

// Image loading statuses
var IMAGE_STATUSES = {
	LOADING : 'LOADING',
	LOADED  : 'LOADED',
	ERROR   : 'ERROR'
};

// check image's status. It's either still loading, loaded or errored
var imageStatus = function(img){
	if(!img.complete){
		return IMAGE_STATUSES.LOADING;
	}
	if(img.naturalWidth === 0){
		return IMAGE_STATUSES.ERROR;
	}
	return IMAGE_STATUSES.LOADED;
};

export var BitVM = can.Map.extend({
	actionFail: null,
	sharePanelOpen: false,
	toggleApproveBit : function(){
		if(this.attr('bit.is_approved')){
			this.disapproveBit();
		} else {
			this.approveBit();
		}
	},
	togglePinBit : function(){
		if(this.attr('bit.is_pinned')){
			this.unpinBit();
		} else {
			this.pinBit();
		}
	},
	actionFailTitle : function(){
		var actionFail = this.attr('actionFail');
		return actionFail === 'disapprove' ? 'block' : actionFail;
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
});

var BIT_ACTIONS = ['pin', 'unpin', 'approve', 'disapprove'];

for(var i = 0; i < BIT_ACTIONS.length; i++){
	BitVM.prototype[BIT_ACTIONS[i] + 'Bit'] = (function(action){
		return function(){
			var self = this;
			var def = this.attr('bit')[action](this.attr('state.hubId'));
			def.fail(function(){
				self.attr('actionFail', action);
			});
		};
	})(BIT_ACTIONS[i]);
}

can.Component.extend({
	tag: 'bh-bit',
	template : initView,
	scope : BitVM,
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
			if(this.scope.attr('state').isAdmin()){
				this.element.toggleClass('blocked', !newVal);
			}
		},
		'{bit} is_pinned' : function(bit, ev, newVal){
			if(this.scope.attr('state').isAdmin()){
				this.element.toggleClass('pinned', newVal);
			}
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
			
			// If any of the images is still loading, check again in 500ms
			if(can.inArray(IMAGE_STATUSES.LOADING, statuses) > -1){
				this.__imgSweeperTimeout = setTimeout(this.proxy('imgSweeper'), 500);
			} else {
				this.doneLoading();
			}

			for(var i = 0; i < statuses.length; i++){
				if(statuses[i] === IMAGE_STATUSES.ERROR){
					errored = this.imgs.splice(i, 1)[0];
					if(errored){
						$(errored).remove();
					}
				}
			}
		},
		// All images in bit are loaded and we can calculate it's height. We set the explicit height
		// to make sure that that the transition animation runs.
		doneLoading : function(){
			if(this.element.hasClass('animate-height')){
				this.element.height(this.element.find('.bit').height());
			}

			this.element.removeClass('loading');
			this.scope.attr('bit').attr('@isLoaded', true);
		},
		// When we're done with the height transition remove the explicit height
		// and mark the bit's height as resolved
		removeExplicitHeight : function(){
			var self = this;
			this.__removeExplicitHeightTimeout = setTimeout(function(){
				if(self.element){
					self.element.trigger('bit:loaded');
					self.element.css('height', 'auto');
				}
				self.scope.attr('bit').attr('@resolvedHeight', true);
			}, 1);
			
		},
		// Clean up the timeouts
		destroy : function(){
			clearTimeout(this.__imgSweeperTimeout);
			clearTimeout(this.__initTimeout);
			clearTimeout(this.__removeExplicitHeightTimeout);
			return this._super.apply(this, arguments);
		}
	}
});
