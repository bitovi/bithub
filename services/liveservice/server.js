var app = require('http').createServer(handler);
var io  = require('socket.io')(app);
var fs  = require('fs');
var Q   = require('q');
var _   = require('lodash');

var	LISTEN_HOST  = process.env.LIVESERVICE_HOST || '127.0.0.1',
	LISTEN_PORT  = process.env.LIVESERVICE_PORT || 3002,
	RABBITMQ_URI = process.env.RABBITMQ_URI,
	REDIS_URL    = process.env.REDIS_URL,
	VERBOSE      = true;

var ENDPOINTS = ['entities', 'services', 'moderation'];

var sessionStore = require('./session_store.js'),
	amqpListener = require('./amqp_listener.js'),
	messageRouter = require('./message_router.js');

function handler(req, res) {
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
}

function parseCookies( cookie ) {
	return _.reduce( cookie.split(';'), function( acc, pair ) {
		pair = pair.split('=');
		var key = pair[0].trim(),
			value = pair[1].trim();

		acc[key] = value;
		return acc;
	}, {} );
};

function registerEndpoints() {
	_.each( ENDPOINTS, function( endpoint ) {
		listener.bindConsumer(endpoint, function( data ) {
			VERBOSE && console.info( 'New message from MQ', data );

			var key = [endpoint, data.meta.brand_name, data.meta.embed_name].join('.');
			router.publish( key, data.payload );
		});
	});
};

function onIoConnection() {
	io.on('connection', function (socket) {
		var cookies = parseCookies( socket.conn.request.headers.cookie ),
			params = socket.handshake.query;

		sessions.read( cookies._session_id, function( err, result ) {
			if( err ) {
				console.error( err );
			} else {
				_.each( ENDPOINTS, function( endpoint ) {
					var key = [endpoint, result.tenant_name, params.embed_name].join('.');

					router.subscribe( key, function( message ) {
						socket.emit( endpoint, message );
					});
				});
			}
		});

	});
}

var sessions = sessionStore.createClient( REDIS_URL, {verbose: VERBOSE} ),
	listener = amqpListener.createClient( RABBITMQ_URI, {verbose: VERBOSE} ),
	router   = new messageRouter( {verbose: VERBOSE} );

Q.all([sessions.onReady(), listener.onReady()]).then( function() {
	registerEndpoints();
	onIoConnection();
}, function() {
	console.log( 'FAILED!', arguments );
});

app.listen( LISTEN_PORT ); //, LISTEN_HOST );
