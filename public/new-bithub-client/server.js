var server = require('can-ssr/lib/server');
var Cookies = require('cookies');

var options = {
  path: process.cwd(),
  liveReload: false,
	configure: function(app){
		app.use(function(req, res, next){
			var cookies = new Cookies(req, res);
			var sessionId = cookies.get('_session_id');
			if(sessionId){
				global.__railsSessionId = sessionId;
			}
			next();
		});
	}
};

var app = server(options);



var port =  process.env.PORT || 3030;
var server = app.listen(port);


server.on('error', function(e) {
	if(e.code === 'EADDRINUSE') {
		console.error('ERROR: Can not start can-serve on port ' + port +
			'.\nAnother application is already using it.');
	} else {
		console.error(e);
		console.error(e.stack);
	}
});

server.on('listening', function() {
	var address = server.address();
	var url = 'http://' + (address.address === '::' ?
			'localhost' : address.address) + ':' + address.port;

	console.log('can-serve starting on ' + url);
});
