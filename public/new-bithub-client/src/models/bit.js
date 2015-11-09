import can from "can";
import moment from "moment";

import "can/list/promise/";
import "can/map/define/";

var Bit = can.Model.extend({
	resource : '/api/v3/embeds/{hubId}/entities',
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

Bit.ACTIONS = ['pin', 'unpin', 'approve', 'disapprove'];

var makeBitAction = function(action){
	var templateUrl = '/api/v3/embeds/{hubId}/entities/{id}/' + action;
	return function(hubId){
		var url = can.sub(templateUrl, {
			hubId : hubId,
			id : this.attr('id')
		});

		return $.ajax(url, {
			dataType: 'json',
			type: 'PUT'
		}).then(function(data){
			Bit.model(data);
		});
	};
};

for(var i = 0; i < Bit.ACTIONS.length; i++){
	Bit.prototype[Bit.ACTIONS[i]] = makeBitAction(Bit.ACTIONS[i]);
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
	}
});

export default Bit;
