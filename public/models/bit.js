steal(
'can/model',
'moment',
'can/list/promise',
'can/map/define',
function(Model, moment){
	
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
							localBuffer[i].created();
						}
						_currentSweeper = null;
					}, 5000)
				}
			}
		}
	})();

	var checkIfBitIsBelowCurrentBit = function(bit, currentBit){
		if(!currentBit){
			return false;
		}
		if(currentBit.is_pinned){
			return true;
		}
		return bit.thread_updated_ts < currentBit.thread_updated_ts;
	}

	var BIT_ACTIONS = ['pin', 'unpin', 'approve', 'disapprove'];

	var instanceMethods = {
		formattedThreadUpdatedAt : function(){
			return moment(this.attr('thread_updated_at')).format('LL');
		},
		isTumblrImage : function(){
			return this.isPhoto() && this.attr('feed_name') === 'tumblr';
		},
		isInstagramImage : function(){
			return this.isPhoto() && this.attr('feed_name') === 'instagram';
		},
		isPhoto : function(){
			return this.attr('type_name') === 'photo';
		},
		isTwitterFollow : function(){
			return this.attr('feed_name') === 'twitter' && this.attr('type_name') === 'follow';
		}
	};

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
			})
		}
	}

	for(var i = 0; i < BIT_ACTIONS.length; i++){
		instanceMethods[BIT_ACTIONS[i]] = makeBitAction(BIT_ACTIONS[i]);
	}

	var Bit = Model.extend({
		ACTIONS: BIT_ACTIONS,
		resource : '/api/v3/embeds/{hubId}/entities',
		messageFromLiveService : function(msg){
			var parsed = JSON.parse(msg);
			parsed._isFromLiveService = true;
			buffer.add(this.model(parsed));
		}
	}, instanceMethods);

	Bit.List = Bit.List.extend({
		place : function(bit){
			var length = this.attr('length');
			var index = -1;
			var currentIndex, currentBit, nextBit;

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

			console.log('INDEX', index)

			
			this.splice(index, 0, bit);
		}
	});

	return Bit;
})

