steal('can/map', 'models', 'can/map/define', function(Map, Models){

	var currentSocket;

	var buffer = [];

	setInterval(function(){
		var localBuffer = buffer.splice(0).reverse();
		for(var i = 0; i < localBuffer.length; i++){
			localBuffer[i].created();
		}
	}, 10000);

	$(window).on('beforeunload', function(){
		currentSocket && currentSocket.close();
	});

	var RELOAD_TIMEOUTS = {};

	return Map.extend({
		define : {
			page : {
				value : 'hub-list'
			},
			hubId : {
				set : function(val){

					this.attr('bits').splice(0);
					
					if(currentSocket && currentSocket.close){
						currentSocket.close();
					}

					if(typeof io !== 'undefined'){
						currentSocket = io('/?embed_id=' + val, { multiplex: false });
						currentSocket.on('connect', function() {
							console.log('CONNECTED!');
						});
						currentSocket.on('connect_error', function() {
							console.log('CONNECTION ERROR!');
						});

						currentSocket.on('entities', function( msg ) {
							var parsed = JSON.parse(msg);
							//console.log('NEW ENTITY', parsed);

							parsed._isFromLiveService = true;

							buffer.push(Models.Bit.model(parsed));
						});

						currentSocket.on('services', function( msg ) {
							var cb = can.noop,
								timeout = 1,
								self = this;

							if(msg.service.empty_results){
								cb = function(service){
									if(service.attr('entity_count') === 0){
										service.hasNoResults();
									}
								}
								timeout = 2000;
							}

							clearTimeout(RELOAD_TIMEOUTS[msg.service.id]);

							RELOAD_TIMEOUTS[msg.service.id] = setTimeout(function(){
								Models.Service.findOne({id: msg.service.id}).then(cb);
							}, timeout);
						});

						currentSocket.on('moderation', function( msg ) {
							console.log( 'New message from moderation', msg );
						});
					}

					return val;
				},
				remove : function(){
					this.attr('bits').splice(0);
				}
			},
			sidebarIsExpanded : {
				value : true,
				serialize: false
			},
			loadingServices : {
				value : [],
				serialize: false
			},
			bits : {
				Value : Models.Bit.List,
				serialize: false
			},
			scrollTop : {
				value : 0,
				serialize: false
			},
			scrollHeight: {
				value : 0,
				serialize: false
			}
		},
		isSidebar : function(){
			return this.attr('page') === 'sidebar' && this.attr('hubId');
		}
	});
});
