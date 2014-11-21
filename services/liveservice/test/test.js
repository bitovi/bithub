//var should = require('should');
var assert = require('assert'),
	Router = require('../message_router.js'),
	SessionStore = require('../session_store.js');

describe('MessageRouter', function() {

	it('routes messages by key', function( done ) {
		var router = new Router(),
			count = 0;

		router.subscribe( 'foobar', function( msg ) {
			msg === 'first' && count++;
			msg === 'second' && count++;
		});

		router.publish( 'foobar', 'first' );
		router.publish( 'foobar', 'second' );

		count == 2 && done();
	});

	it('do not mixes keys', function( done ) {
		var router = new Router(),
			count = 0;

		router.subscribe( 'foo', function( msg ) {
			msg === 'msg4foo' && count++;
		});
		router.subscribe( 'bar', function( msg ) {
			msg === 'msg4bar' && count++;
		});
		router.subscribe( 'dummy', function( msg ) {
			count++; // should be ever called
		});

		router.publish( 'foo', 'msg4foo' );
		router.publish( 'bar', 'msg4bar' );
		router.publish( 'baz', 'msg4baz' ); // should not route

		count == 2 && done();
	});
});

describe('SessionStore', function() {
	describe('#parseUrl', function() {
		it('parsed connection url to redis', function() {
			var parsed = SessionStore.parseUrl( 'redis://127.0.0.1:1234/15');

			assert.equal( parsed.host, '127.0.0.1' );
			assert.equal( parsed.port, 1234 );
			assert.equal( parsed.db, 15 );
		});
	});
});
