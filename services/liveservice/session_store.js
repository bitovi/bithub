var redis = require('redis');
var Q     = require('q');

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
	opts = opts || {};

	var self = this,
		params = parseUrl( url ),
		client = redis.createClient( params.port, params.host );

	this.ready   = Q.defer();
	this.verbose = opts.verbose;
	this.timeout = opts.timeout || 5000;

	client.on('connect', function() {
		self.verbose && console.info('Connected to redis on ' + params.host + ':' + params.port);

		client.select( params.db, function( err, status ) {
			if( err ) {
				console.error( 'Redis error: ' + err );
				self.ready.reject( err );
			} else {
				self.verbose && console.info( 'Redis using database ' + params.db );
				self.ready.resolve( status );
			}
		});
	});

	client.on('error', function( err ) {
		self.ready.reject( err );
	});

	this.client = client;
	this.params = params;
};

Client.prototype.read = function( session_id, cb ) {
	this.client.get( 'session:' + session_id, function( err, result ) {
		cb( err, JSON.parse( result ) );
	});
};

Client.prototype.onReady = function() {
	return Q.timeout(this.ready.promise, this.timeout);
};


module.exports = {
	createClient: function( url, opts ) {
		return new Client( url, opts );
	},
	parseUrl: parseUrl
};
