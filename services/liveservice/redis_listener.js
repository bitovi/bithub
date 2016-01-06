var Q  = require('q'),
	redis = require('redis');

var makeFetcher = function(client, queues, dispatcher){
	var index = 0;
	var fetch = function(i){
		var queue = queues[i];
		return client.brpop(queue, 1, function(err, res){
			if(!res) {
				nextFetch();
			} else {

				try {
					dispatcher({ queueName: res[0], data: JSON.parse(res[1]) });
				} catch (e) {
					console.error(e, res);

				}
				
				nextFetch(i);
			}
		});
	}
	var nextFetch = function(nextIndex){
		process.nextTick(function(){
			if(typeof nextIndex === 'undefined'){
				index++;
				if(index >= queues.length){
					index = 0;
				}
				nextIndex = index;
			}
			return fetch(nextIndex);
		})
		
	}
	return nextFetch;
}


function Client( opts ){
	var self = this;

	this.ready = Q.defer();
	this.timeout  = opts.timeout || 5000;

	this.conn = redis.createClient();
	this.conn.on('ready', function(){
		self.conn.select(15, function() {
			self.ready.resolve('OK');
		});
	});
	
}

Client.prototype.listen = function(queues, dispatcher){
	var fetch = makeFetcher(this.conn, queues, dispatcher);
	fetch(0);
}

Client.prototype.onReady = function( cb ) {
	return Q.timeout(this.ready.promise, this.timeout);
};

module.exports = {
	createClient: function( opts ) {
		return new Client( opts );
	}
};
