var amqp = require('amqp');
var Q     = require('q');

var Client = function( url, opts ) {
	opts = opts || {};

	var self = this;

	this.conn     = amqp.createConnection({url: url});
	this.exchange = null;
	this.ready    = Q.defer();
	this.verbose  = opts.verbose;
	this.timeout  = opts.timeout || 5000;

	var exchangeName = opts.exchangeName || 'x.liveservice',
		exchangeType = opts.exchangeType || 'direct';

	this.conn.on('ready', function() {
		self.verbose && console.info("Connected to " + self.conn.serverProperties.product);
		self.exchange = self.conn.exchange( exchangeName, { type: exchangeType }, function( ex ) {
			self.ready.resolve('OK');
		});
	});
};

Client.prototype.bindConsumer = function( routingKey, cb ) {
	var self = this,
		conn = this.conn,
		queueName = 'q.liveservice.' + routingKey;

	conn.queue( queueName , {autodelete: false}, function( q ) {
		q.bind( self.exchange, routingKey, function() {
			self.verbose && console.info('Binded queue ' + queueName);
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
	return Q.timeout(this.ready.promise, this.timeout);
};

module.exports = {
	createClient: function( uri, opts ) {
		return new Client( uri, opts );
	}
};
