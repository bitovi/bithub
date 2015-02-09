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
			var length = this.attr('length'),
				currentBit, nextBit;
			for(var i = 0; i < length; i++){
				currentBit = this[i];
				nextBit = this[i + 1];
				if(i === 0 && bit.thread_updated_ts > currentBit.thread_updated_ts){
					this.unshift(bit)
					return;
				} else if(bit.thread_updated_ts < currentBit.thread_updated_ts && (nextBit && bit.thread_updated_ts >= nextBit.thread_updated_ts)){
					this.splice(i, 0, bit);
					return;
				}
			}
			this.push(bit);
		}
	});

	return Bit;
})

