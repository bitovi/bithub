var _ = require('lodash');

var Router = function() {
	this.channels = [];
};

Router.prototype.subscribe = function( key, cb ) {
	var matched = _.select( this.channels, function( channel ) {
		return channel.routingKey == key;
	})[0];

	if( matched ) {
		matched.subscribers.push( cb );
	} else {
		this.channels.push({
			routingKey: key,
			subscribers: [cb]
		});
	}
};

Router.prototype.publish = function( key, message ) {
	_.each( this.channels, function( ch ) {
		if( ch.routingKey == key ) {
			_.each(ch.subscribers, function( subscriber ) {
				subscriber( message );
			});
		}
	});
};

Router.prototype.channels = function() {
	return this.channels;
};

module.exports = Router;
