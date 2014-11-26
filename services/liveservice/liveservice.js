var http = require('http'),
	IO   = require('socket.io'),
	fs   = require('fs'),
	Q    = require('q'),
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

var parseCookies = function( cookie ) {
	return _.reduce( cookie.split(';'), function( acc, pair ) {
		pair = pair.split('=');
		var key   = pair[0].trim(),
			value = pair[1].trim();

		acc[key] = value;
		return acc;
	}, {} );
};

var LiveService = function( opts ) {
	opts = opts || {};

	this.host        = opts.host        || process.env.LIVESERVICE_HOST || '127.0.0.1';
	this.port        = opts.port        || process.env.LIVESERVICE_PORT || 3002;
	this.rabbitmqUri = opts.rabbitmqUri || process.env.RABBITMQ_URI;
	this.redisUrl    = opts.redisUrl    || process.env.REDIS_URL;
	this.verbose     = opts.verbose     || true;
	this.endpoints   = opts.endpoints   || ENDPOINTS;

	this.app = http.createServer( indexHandler );
	this.io  = IO( this.app );

	this.sessions = sessionStore.createClient( this.redisUrl, {verbose: this.verbose} ),
	this.listener = amqpListener.createClient( this.rabbitmqUri, {verbose: this.verbose} ),
	this.router   = new messageRouter( {verbose: this.verbose} );
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
			self.verbose && console.info( 'New message from MQ', data );

			var key = [endpoint, data.meta.brand_name, data.meta.embed_name].join('.');
			self.router.publish( key, data.payload );
		});
	});
};

LiveService.prototype.onIoConnection = function() {
	var self = this;

	this.io.on('connection', function (socket) {
		var	params = socket.handshake.query,
			cookie = socket.conn.request.headers.cookie;

		var session_id = params.session_id || parseCookies( cookie )._session_id;

		self.sessions.read( session_id, function( err, result ) {
			if( err ) {
				console.error( err );
			} else {
				_.each( self.endpoints, function( endpoint ) {
					var key = [endpoint, result.tenant_name, params.embed_name].join('.');

					self.router.subscribe( key, function( message ) {
						socket.emit( endpoint, message );
					});
				});
			}
		});

	});
};

module.exports = {
	createServer: function() {
		return new LiveService( arguments );
	}
};
