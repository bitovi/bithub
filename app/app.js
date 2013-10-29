/* Load external moduels */
var express = require('express'),
	socketio = require('socket.io'),
	http = require('http'),
	amqp = require('amqp');

/* Load libs, helpers, middleware, globals */
var middleware = require('./lib/middleware');

/* Read env vars */
var LISTEN_PORT  = process.env.PORT || 3000,
	LISTEN_HOST  = process.env.HOST || '127.0.0.1',
	RABBITMQ_URI = process.env.RABBITMQ_URI;

/* Check if config is valid */
if( !RABBITMQ_URI ) {
	console.log("RabbitMQ connection config is missing");
	process.exit(1);
}

/* Init */
var app = express(),
	server = http.createServer(app),
	io = socketio.listen(server);

/* Configure the app */
app.configure(function(){
	//app.use( middleware.allowCrossDomain );
	//app.use( express.favicon() );
	//app.use( express.logger('dev') );
	//app.use( express.bodyParser() );
	//app.use( express.methodOverride() );
	//app.use( app.router );
	app.use( express.static(__dirname + '/../public') );
});

/* Connect to RabbitMQ */
var connection = amqp.createConnection({url: RABBITMQ_URI});

/* Message queue listener function */
var queueListener = function( message, headers, deliveryInfo ) {
	try {
		var data = JSON.parse(message.data);
		io.sockets && io.sockets.emit('new_event', data);
	} catch (e) {
		console.error(e)
	}
};

/* Subscribe to live feed */
connection.on('ready', function () {
	console.log("Connected to " + connection.serverProperties.product);

	/* create an exchange */
	var e = connection.exchange("e.events.liveservice", { type: 'direct' });
	e.on('open', function() {
		console.log("Exchange " + e.name + " opened");

		/* create a queue and bind it to exchange */
		connection.queue('q.events.liveservice', {autoDelete: false}, function(q) {
			q.bind(e, '');
			q.on('queueBindOk', function() {
				console.log("Queue " + q.name + " binded to " + e.name);				
				q.subscribe(queueListener);
			});
		});
	});
});

/* Start HTTP server */
server.listen(LISTEN_PORT, LISTEN_HOST, function() {
	console.log("Server listening on port:", LISTEN_PORT);
});
	


