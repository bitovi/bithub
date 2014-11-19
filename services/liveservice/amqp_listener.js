var amqp = require('amqp');

var Client = function( url, opts ) {
	var self = this,
		opts = opts || {};

	this.conn     = amqp.createConnection({url: url});
	this.exchange = null;

	var exchangeName = opts.exchangeName || 'x.liveservice',
		exchangeType = opts.exchangeType || 'direct';

	this.conn.on('ready', function() {
		console.info("Connected to " + self.conn.serverProperties.product);
		self.exchange = self.conn.exchange( exchangeName, { type: exchangeType });
	});
};

Client.prototype.bindConsumer = function( routingKey, cb ) {
	var self = this,
		conn = this.conn,
		queueName = 'q.liveservice.' + routingKey;

	conn.queue( queueName , {autodelete: false}, function( q ) {
		q.bind( self.exchange, routingKey, function() {
			console.info('Binded queue ' + queueName);
			q.subscribe( function( message, headers, deliveryInfo, messageObject ) {
				try {
					cb( JSON.parse( message.data ) );
				} catch (e) {
					console.error(e);
				}
			});
		} );
	});
};

Client.prototype.onReady = function( cb ) {
	var self = this;

	self.conn.on('ready', function() {
		self.exchange.on('open', function() { cb(self); });
	});
};

module.exports = {
	createClient: function( uri, opts ) {
		return new Client( uri, opts );
	}
};
