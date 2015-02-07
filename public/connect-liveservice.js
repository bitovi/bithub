steal(function(){
	var currentSocket;

	return function(hubId){

		if(currentSocket && currentSocket.close){
			currentSocket.close();
		}

		if(typeof io !== 'undefined'){
			currentSocket = io('/?embed_id=' + hubId, { multiplex: false });

			/*currentSocket.on('connect', function() {
				console.log('CONNECTED!');
			});

			currentSocket.on('connect_error', function() {
				console.log('CONNECTION ERROR!');
			});

			currentSocket.on('moderation', function( msg ) {
				console.log( 'New message from moderation', msg );
			});*/
			return currentSocket;
		}
	}
});