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

var parseCookies = function( cookie ) {
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

var meta_to_log_format = function( meta ) {
	var msg = [meta.brand_name, meta.embed_id, meta.is_public].join(' ');
	return '[' + msg + ']';
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
	this.router   = new messageRouter( {quite: this.quite} );
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
			self.quite || console.info( ['New message from channel', endpoint, meta_to_log_format(data.meta)].join(' ') );

			var key = [endpoint, data.meta.brand_name, data.meta.embed_id].join('.');
			self.router.publish( key, data );
		});
	});
};

LiveService.prototype.onIoConnection = function() {
	var self = this;

	this.io.on('connection', function (socket) {
		var	params   = socket.handshake.query,
			cookie   = socket.conn.request.headers.cookie,
			remoteIp = socket.conn.remoteAddress;

		var session_id = params.session_id || (cookie && parseCookies( cookie )._session_id);

		if( session_id == undefined ) {
			// Handle public entities
			if(params.tenant_name){
				var publicKey = ['entities', params.tenant_name, params.embed_id].join('.');
				self.router.subscribe(publicKey, function(data){
					if(data.meta.is_public){
						socket.emit('entities', data.payload);
					}
				});
				console.log('Connecting public entities for tenant: ' + params.tenant_name);
			} else {
				console.log('User without valid session from ' + remoteIp);
			}

			return;
		}

		self.sessions.read( session_id, function( err, result ) {
			if( err ) {
				console.error( err );
			} else {
				if( result == null ) {
					console.log('No session data for session ' + session_id + ' from ' + remoteIp);
					return;
				}

				_.each( self.endpoints, function( endpoint ) {
					var key = [endpoint, result.tenant_name, params.embed_id].join('.');

					self.router.subscribe( key, function( data ) {
						var message = data.payload;
						socket.emit( endpoint, message );
					});
				});
			}
		});

	});
};

module.exports = {
	createServer: function( opts ) {
		return new LiveService( opts );
	}
};
