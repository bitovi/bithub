steal('can/model', 'moment', 'can/list/promise', function(Model, moment){
	var Bit = Model.extend({
		resource : '/api/v3/embeds/{hubId}/entities'
	}, {
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
		}
	});

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

