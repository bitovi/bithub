var redis = require('redis');

var parseUrl = function( url ) {
	var re = /redis:\/\/([\d\.]+):(\d+)\/(\d+)/g;
	var parsed = re.exec(url);

	return parsed && {
		host: parsed[1],
		port: parseInt( parsed[2] ),
		db: parseInt( parsed[3] )
	};
};

var Client = function( url, opts ) {
	var params = parseUrl( url );
	var client = redis.createClient( params.port, params.host );

	client.select( params.db, function( err, status ) {
		if( err ) {
			console.error( 'Redis error: ' + err );
		} else {
			console.info( 'Redis using database ' + params.db );
		}
	});

	client.on('connect', function() {
		console.info('Connected to redis on ' + params.host + ':' + params.port);
	});

	this.client = client;
	this.params = params;
};

Client.prototype.read = function( session_id, cb ) {
	this.client.get( 'session:' + session_id, function( err, result ) {
		cb( err, JSON.parse( result ) );
	});
};

module.exports = {
	createClient: function( url, opts ) {
		return new Client( url, opts );
	}
};
