var http = require('http'),
	IO   = require('socket.io'),
	fs   = require('fs'),
	Q    = require('q'),
	pm   = require('newrelic'),
	_    = require('lodash');

var sessionStore  = require('./session_store.js'),
	amqpListener  = require('./amqp_listener.js'),
	messageRouter = require('./message_router.js');

var ENDPOINTS = ['entities', 'services', 'moderation'];

var indexHandler = function( req, res ) {
	fs.readFile(
		__dirname + '/index.html',
		function (err, data) {
			if (err) {
				res.writeHead(500);
				return res.end('Error loading index.html');
			}
			res.writeHead(200);
			res.end(data);
		});
};

var _parseCookies = function( cookie ) {
	return _.reduce( cookie.split(';'), function( acc, pair ) {
		pair = pair.split('=');

		// care only about key/value pairs
		if( pair.length != 2 ) return acc;

		var key   = pair[0].trim(),
			value = pair[1].trim();

		acc[key] = value;
		return acc;
	}, {} );
};

var _logNewMessage = function( endpoint, message ) {
	var meta = message.meta;
	var output = [endpoint, meta.brand_name, meta.embed_id, meta.is_public].join(' ');

	console.log( 'New message from MQ (endpoint, brand, embed, public?): [' + output + ']' );
};

var _logNewSubscription = function( routingKey, session ) {
	console.log( 'New subscription (routingKey, session): [' + routingKey + ' ' + session + ']' );
};

var _logRouterState = function( router ) {
	console.log( 'Router channels state (routingKey, subscribersCount) -----------');
	_.each( router.channels, function( ch ) {
		console.log( ch.routingKey, ch.subscribers.length );
	});
};

var LiveService = function( opts ) {
	opts = opts || {};

	this.host        = opts.host        || process.env.LIVESERVICE_HOST || '127.0.0.1';
	this.port        = opts.port        || process.env.LIVESERVICE_PORT || 3002;
	this.rabbitmqUri = opts.rabbitmqUri || process.env.RABBITMQ_URI;
	this.redisUrl    = opts.redisUrl    || process.env.REDIS_URL;
	this.endpoints   = opts.endpoints   || ENDPOINTS;
	this.quite       = opts.quite       || false;

	this.app = http.createServer( indexHandler );
	this.io  = IO( this.app );

	this.sessions = sessionStore.createClient( this.redisUrl, {quite: this.quite} ),
	this.listener = amqpListener.createClient( this.rabbitmqUri, {quite: this.quite} ),
	this.router   = new messageRouter();
};

LiveService.prototype.listen = function() {
	var self = this;

	Q.all([self.sessions.onReady(), self.listener.onReady()]).then( function() {
		self.app.listen( self.port );
		self.registerEndpoints();
		self.onIoConnection();
	}, function() {
		console.log( 'FAILED!', arguments );
	});
};

LiveService.prototype.registerEndpoints = function() {
	var self = this;

	_.each( self.endpoints, function( endpoint ) {
		self.listener.bindConsumer(endpoint, function( data ) {
			self.quite || _logNewMessage( endpoint, data );

			var key = [endpoint, data.meta.brand_name, data.meta.embed_id].join('.');
			self.router.publish( key, data );
		});
	});
};

LiveService.prototype.onIoConnection = function() {
	var self = this;

	this.io.on('connection', function(socket) {
		var	params   = socket.handshake.query,
			cookie   = socket.conn.request.headers.cookie,
			remoteIp = socket.conn.remoteAddress;

		var session_id = params.session_id || (cookie && _parseCookies( cookie )._session_id);
		var subscriptions = [];

		socket.on('disconnect', function() {
			while(subscriptions.length > 0) {
				var sub = subscriptions.shift();
				self.router.unsubscribe(sub.routingKey, sub.emitter);

				self.quite || console.log( 'Unsubscribed from ' + sub.routingKey );
				self.quite || _logRouterState( self.router );
			};
		});

		if( session_id == undefined ) {
			if( !params.tenant_name ) return;

			var routingKey = ['entities', params.tenant_name, params.embed_id].join('.');
			var emitter  = function(data){
				if(data.meta.is_public){
					socket.emit('entities', data.payload);
				}
			};

			self.quite || _logNewSubscription( routingKey, 'public' );
			self.router.subscribe(routingKey, emitter );
			subscriptions.push( {routingKey: routingKey, emitter: emitter} );
		} else {
			self.sessions.read( session_id, function( err, result ) {
				if( err ) {
					console.error( err );
				} else {
					if( result == null ) {
						console.log('No session data for session ' + session_id + ' from ' + remoteIp);
						return;
					}

					_.each( self.endpoints, function( endpoint ) {
						var routingKey = [endpoint, result.tenant_name, params.embed_id].join('.');
						var emitter  = function( data ) {
							socket.emit( endpoint, data.payload );
						};

						self.quite || _logNewSubscription( routingKey, session_id );
						self.router.subscribe( routingKey, emitter );
						subscriptions.push( {routingKey: routingKey, emitter: emitter} );
					});
				}
			});
		}
	});
};

module.exports = {
	createServer: function( opts ) {
		return new LiveService( opts );
	}
};
