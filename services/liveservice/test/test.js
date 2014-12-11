var assert       = require('assert'),
	dotenv       = require('dotenv'),
	Q            = require('q'),
	io           = require('socket.io-client'),
	Router       = require('../message_router.js'),
	SessionStore = require('../session_store.js'),
	AmqpListener = require('../amqp_listener.js'),
	LiveService  = require('../liveservice.js');

// load .env so we don't have to set connection params manually
dotenv._getKeysAndValuesFromEnvFilePath('../../.env');
dotenv._setEnvs();

describe('The Universe', function() {
	var sessions = SessionStore.createClient( process.env.REDIS_URL, { quite: true } ),
		mq = AmqpListener.createClient( process.env.RABBITMQ_URI, { quite: true } ),
		liveservice = LiveService.createServer({quite: true});

	var clients = {
		uno: { session_id: 'test_session_uno', tenant_name: 'test_tenant_uno'},
		duo: { session_id: 'test_session_duo', tenant_name: 'test_tenant_duo'}
	};

	var websocketUrl = function( embed_id, session_id )  {
		return 'http://127.0.0.1:' + process.env.LIVESERVICE_HTTP_PORT +
			'/?embed_id=' + embed_id +
			'&session_id=' + session_id;
	};

	// create fake sessions that will expire soon
	before( function() {
		for( var key in clients ) {
			sessions.create( clients[key].session_id, {tenant_name: clients[key].tenant_name}, function( err, data ) {
				if(err) { throw new Error(err); }
			}, {expire: 30} );
		}
	});

	it('spins', function( done ) {
		this.timeout( 10000 ); // be generous

		var wsUnoFooReady = Q.defer(), wsUnoBarReady = Q.defer(), wsDuoFooReady = Q.defer();
		var wsUnoFooCount = 0, wsUnoBarCount = 0, wsDuoFooCount = 0;

		var wsUnoFoo = io( websocketUrl( 'embed_uno_foo', clients.uno.session_id), { multiplex: false } ),
			wsUnoBar = io( websocketUrl( 'embed_uno_bar', clients.uno.session_id), { multiplex: false } ),
			wsDuoFoo = io( websocketUrl( 'embed_duo_foo', clients.duo.session_id), { multiplex: false } );

		wsUnoFoo.on('entities', function( msg ) {
			if( msg.id == 'msg_4_uno_foo' ) {
				wsUnoFooCount++;
			} else {
				throw new Error('[wsUnoFoo] undesirable msg: ' + msg.id);
			}
		});

		wsUnoBar.on('entities', function( msg ) {
			if( msg.id == 'msg_4_uno_bar' ) {
				wsUnoBarCount++;
			} else {
				throw new Error('[wsUnoBar] undesirable msg: ' + msg.id);
			}
		});

		wsDuoFoo.on('entities', function( msg ) {
			if( msg.id == 'msg_4_duo_foo' ) {
				wsDuoFooCount++;
			} else {
				throw new Error('[wsDuoFoo] undesirable msg: ' + msg.id);
			}
		});

		// resolve when clients are connected
		wsUnoFoo.on('connect', function() { wsUnoFooReady.resolve('OK'); });
		wsUnoBar.on('connect', function() {	wsUnoBarReady.resolve('OK'); });
		wsDuoFoo.on('connect', function() { wsDuoFooReady.resolve('OK'); });

		// start publishing after all clients are connected
		Q.all([ wsUnoFooReady.promise, wsUnoBarReady.promise, wsDuoFooReady.promise ]).then( function() {

			// 1x uno foo
			mq.publish('entities',{ meta: { brand_name: clients.uno.tenant_name, embed_id: 'embed_uno_foo' },
									payload: { id: 'msg_4_uno_foo'} });

			// 2x uno bar
			mq.publish('entities',{ meta: { brand_name: clients.uno.tenant_name, embed_id: 'embed_uno_bar' },
									payload: { id: 'msg_4_uno_bar'} });
			mq.publish('entities',{ meta: { brand_name: clients.uno.tenant_name, embed_id: 'embed_uno_bar' },
									payload: { id: 'msg_4_uno_bar'} });

			// 1x duo foo
			mq.publish('entities',{ meta: { brand_name: clients.duo.tenant_name, embed_id: 'embed_duo_foo' },
									payload: { id: 'msg_4_duo_foo'} });

			// 1x duo bar (non existing embed)
			mq.publish('entities',{ meta: { brand_name: clients.duo.tenant_name, embed_id: 'embed_duo_bar' },
									payload: { id: 'msg_4_duo_bar'} });

			// 1x tre baz (non existing tenant)
			mq.publish('entities',{ meta: { brand_name: 'test_tenant_tre', embed_id: 'embed_tree_baz' },
									payload: { id: 'msg_4_tre_baz'} });

			// give it some time before checking results
			setTimeout(function() {
				wsUnoFooCount == 1 && wsUnoBarCount == 2 && wsDuoFooCount == 1 && done();
			}, 2000);
		});

		// start liveservice
		liveservice.listen();
	});
});

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
