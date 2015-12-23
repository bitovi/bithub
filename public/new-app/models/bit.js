import can from "can";
import Bit from "opensourced-bithub/models/bit";

import "can/list/promise/";
import "can/map/define/";

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
