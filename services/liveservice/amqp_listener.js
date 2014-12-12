var amqp = require('amqp');
var Q     = require('q');

var Client = function( url, opts ) {
	opts = opts || {};

	var self = this;

	this.conn     = amqp.createConnection({url: url});
	this.exchange = null;
	this.ready    = Q.defer();
	this.quite    = opts.quite;
	this.timeout  = opts.timeout || 5000;

	var exchangeName = opts.exchangeName || 'x.liveservice',
		exchangeType = opts.exchangeType || 'direct';

	this.conn.on('ready', function() {
		self.quite || console.info("Connected to " + self.conn.serverProperties.product);
		self.exchange = self.conn.exchange( exchangeName, { type: exchangeType }, function( ex ) {
			self.ready.resolve('OK');
		});
	});
};

Client.prototype.bindConsumer = function( routingKey, cb ) {
	var self = this,
		queueName = 'q.liveservice.' + routingKey;

	this.conn.queue( queueName , {autoDelete: false}, function( q ) {
		q.bind( self.exchange, routingKey, function() {
			self.quite || console.info('Binded queue ' + queueName);
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

Client.prototype.publish = function( routingKey, msg, cb ) {
	if( typeof(msg) != "string" ) {
		msg = JSON.stringify( msg );
	}
	this.exchange.publish( routingKey, msg, {}, cb );
};

Client.prototype.onReady = function( cb ) {
	return Q.timeout(this.ready.promise, this.timeout);
};

module.exports = {
	createClient: function( uri, opts ) {
		return new Client( uri, opts );
	}
};
