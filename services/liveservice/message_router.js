var _ = require('lodash');

var Router = function( opts ) {
	this.channels = [];
};

var _deleteChannel = function( key ) {
	return _.remove(this.channels, function( ch ) {
		return ch.routingKey == key;
	});
};

var _deleteSubscription = function( channel, fn ) {
	return _.remove(channel.subscribers, function( sub ) {
		return sub == fn;
	});
};

var _subscriptionsByKey = function( channels, key ) {
	return  _.result(_.find( channels, function( channel ) {
		return channel.routingKey == key;
	}), 'subscribers');
};

Router.prototype.subscribe = function( key, cb ) {
	var subscriptions = _subscriptionsByKey( this.channels, key );

	if( subscriptions ) {
		subscriptions.push( cb );
	} else {
		this.channels.push({
			routingKey: key,
			subscribers: [cb]
		});
	}
};

Router.prototype.unsubscribe = function( key, cb ) {
	_.remove( this.channels, function( channel ) {
		if( !key || channel.routingKey == key ) {
			_deleteSubscription( channel, cb );

			// remove if empty
			return (channel.subscribers.length == 0);
		} else {
			return false;
		}
	});
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

Router.prototype.subscriptions = function( key ) {
	return _subscriptionsByKey( this.channels, key );
};

module.exports = Router;
