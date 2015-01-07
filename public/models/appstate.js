steal('can/map', 'models', 'can/map/define', function(Map, Models){

	var currentSocket;

	return Map.extend({
		define : {
			page : {
				value : 'hub-list'
			},
			hubId : {
				set : function(val){
					
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
							console.log('NEW ENTITY');

							parsed._isFromLiveService = true;

							var entity = Models.Bit.model(parsed);
							entity.created();
						});

						currentSocket.on('service_errors', function(msg){
							console.log('SERVICE ERRORS', msg)
							Models.Service.findOne(JSON.parse(msg));
						})

						currentSocket.on('services', function( msg ) {
							console.log( 'New message from services', msg );
						});

						currentSocket.on('moderation', function( msg ) {
							console.log( 'New message from moderation', msg );
						});
					}

					return val;
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