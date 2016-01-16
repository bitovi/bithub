import can from "can";
import moment from "moment";

import "can/list/promise/";
import "can/map/define/";

var Bit = can.Model.extend({
	resource : '/api/v4/embeds/{hubId}/entities',
}, {
	define : {
		thread_updated_at: {
			set : function(val){
				var momentThreadUpdatedAt = moment(val);
				this.attr({
					formattedThreadUpdatedAt: momentThreadUpdatedAt.format('LL'),
					formattedThreadUpdatedAtDate: momentThreadUpdatedAt.format('YYYY-MM-DD')
				});
				return val;
			}
		}
	},
	isTumblrImage : function(){
		return this.isPhoto() && this.isTumblr();
	},
	isInstagramImage : function(){
		return this.isPhoto() && this.attr('feed_name') === 'instagram';
	},
	isPhoto : function(){
		return this.attr('type_name') === 'photo';
	},
	isTumblr : function(){
		return this.attr('feed_name') === 'tumblr';
	},
	isTwitterFollow : function(){
		return this.attr('feed_name') === 'twitter' && this.attr('type_name') === 'follow';
	},
	isYoutube : function(){
		return this.attr('feed_name') === 'youtube';
	},
	youtubeEmbedURL : function(){
		return this.attr('url').replace(/watch\?v=/, 'embed/');
	}
});


Bit.DECISIONS = ['pending', 'starred', 'deleted', 'approved'];

var makeBitAction = function(decision){
	var templateUrl = '/api/v4/embeds/{hubId}/entities/{id}/decide/?decision={decision}';
	return function(hubId){
		var realDecision = decision;
		var currentDecision = this.attr('decision');
		
		if(decision === currentDecision){
			realDecision = 'pending';
		}

		var url = can.sub(templateUrl, {
			hubId : hubId,
			id : this.attr('id'),
			decision: realDecision
		});

		return $.ajax(url, {
			dataType: 'json',
			type: 'PUT'
		}).then(function(data){
			can.trigger(Bit, 'decision', [currentDecision, realDecision]);
			var bit = Bit.model(data);
			bit.updated();
		});
	};
};

for(var i = 0; i < Bit.DECISIONS.length; i++){
	Bit.prototype['decide' + can.capitalize(Bit.DECISIONS[i])] = makeBitAction(Bit.DECISIONS[i]);
}

var checkIfBitIsBelowCurrentBit = function(bit, currentBit){
	if(!currentBit){
		return false;
	}
	if(currentBit.is_pinned){
		return true;
	}
	return bit.thread_updated_ts < currentBit.thread_updated_ts;
};

var isFullBit = function(bit){
	return !!bit.created_at;
};

var buffer = (function(){
	var _buffer = [];
	var _currentSweeper;

	return {
		add : function(bit){
			_buffer.push(bit);
			if(!_currentSweeper){
				_currentSweeper = setTimeout(function(){
					var localBuffer = _buffer.splice(0).reverse();
					for(var i = 0; i < localBuffer.length; i++){
						can.trigger(Bit, 'lifecycle', [localBuffer[i]]);
					}
					_currentSweeper = null;
				}, 5000);
			}
		}
	};
})();

Bit.messageFromLiveService = function(msg){
	var parsed = JSON.parse(msg);
	parsed._isFromLiveService = true;

	if(this.store[parsed.id]){
		this.store[parsed.id].attr(parsed);
	} else if(isFullBit(parsed)){
		buffer.add(this.model(parsed));
	}
	if(!parsed.is_approved){
		can.trigger(Bit, 'disapproved', [this.store[parsed.id]]);
	}
};

Bit.List = Bit.List.extend({
	place : function(bit){
		var index = -1;
		var currentIndex, currentBit;
		
		this.attr('length');

		currentIndex = this.indexOf(bit);

		// if it exists in the list remove it because we are changing the order
		if(currentIndex > -1){
			this.splice(currentIndex, 1);
		}

		if(bit.attr('is_pinned')){
			do {
				index++;
				currentBit = this.attr(index);
			} while(currentBit && currentBit.attr('is_pinned'));
		} else {
			do {
				index++;
				currentBit = this.attr(index);
			} while(checkIfBitIsBelowCurrentBit(bit, currentBit));
		}

		this.splice(index, 0, bit);
	},
	remove : function(bit){
		var index = this.indexOf(bit);
		if(index > -1){
			this.splice(index, 1);
		}
	},
	loadNextPage: function(){
		var length = this.attr('length');
		var count = this.__totalCount;
		var self = this;

		if(typeof count !== 'undefined' || length < this.__totalCount){
			this.__loadingParams.offset = length;
		}
		if(!this.attr('isCurrentlyLoading') && (!this.__totalCount || length < this.__totalCount)){
			this.attr('isCurrentlyLoading', true);
			return Bit.findAll(this.__loadingParams).then(function(data){
				self.__totalCount = data.count;
				self.push.apply(self, data);
				setTimeout(function(){
					self.attr('isCurrentlyLoading', false);
				});
			});
		}
	},
	refresh : function(cb){
		var params = this.__loadingParams;
		var self = this;
		Bit.findAll(params).then(function(data){
			var current;
			var counter = 0;
			for(var i = 0; i < data.length; i++){
				current = data[i];
				if(self.indexOf(current) === -1){
					self.unshift(current);
					counter++;
				}
			}
			cb(counter);
		});
		
	},
	isLoading : function(){
		return this.attr('length') === 0 && this.attr('isCurrentlyLoading');
	}
});

export default Bit;
