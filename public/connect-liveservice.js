steal(function(){
	var currentSocket;

	$(window).on('beforeunload', function(){
		currentSocket && currentSocket.close && currentSocket.close();
	});

	var url = '/?embed_id={embedId}';
	var publicUrl = '/?embed_id={embedId}&tenant_name={tenantName}'

	return function(hubId, tenantName){

		if(currentSocket && currentSocket.close){
			currentSocket.close();
		}

		if(typeof io !== 'undefined'){
			console.log(can.sub((tenantName ? publicUrl : url), {
				embedId : hubId,
				tenantName : tenantName
			}))
			currentSocket = io(can.sub((tenantName ? publicUrl : url), {
				embedId : hubId,
				tenantName : tenantName
			}), { multiplex: false });

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