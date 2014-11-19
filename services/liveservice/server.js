var app = require('http').createServer(handler);
var io  = require('socket.io')(app);
var fs  = require('fs');
var _   = require('lodash');

var sessionStore = require('./session_store.js'),
	amqpListener = require('./amqp_listener.js'),
	messageRouter = require('./message_router.js');

var	LISTEN_HOST  = process.env.LIVESERVICE_HOST || '127.0.0.1',
	LISTEN_PORT  = process.env.LIVESERVICE_PORT || 3002,
	RABBITMQ_URI = process.env.RABBITMQ_URI,
	REDIS_URL    = process.env.REDIS_URL;

app.listen(3002);

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

var parseCookie = function( cookie ) {
	return _.reduce( cookie.split(';'), function( acc, pair ) {
		pair = pair.split('=');
		var key = pair[0].trim(),
			value = pair[1].trim();

		acc[key] = value;
		return acc;
	}, {} );
};

var sessions = sessionStore.createClient( REDIS_URL ),
	listener = amqpListener.createClient( RABBITMQ_URI ),
	router   = new messageRouter();

listener.onReady( function(l) {
	l.bindConsumer('entities', function( data ) {
		console.info( 'New message from MQ', data );

		//var key = ['entities', data.meta.brand_name, data.meta.embed_name].join('.');
		var key = ['entities', data.meta.brand_name].join('.');
		router.publish( key, data.payload );
	});
});

io.on('connection', function (socket) {
	var cookies = parseCookie( socket.conn.request.headers.cookie );

	sessions.read( cookies._session_id, function( err, result ) {
		if( err ) {
			console.error( err );
		} else {
			var key = ['entities', result.tenant_name].join('.');

			// subscribe/register on router
			router.subscribe( key, function( message ) {
				socket.emit( 'entities', message );
			});
		}
	});

});
