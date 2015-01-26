steal(
'./bind-model-events.js',
'models/appstate.js',
'./embed.stache!',
'bits',
'can/route',
'style',
function(bindModelEvents, AppState, embedView){

	var params = can.deparam(window.location.search.substr(1));
	var hubId = params.hubId;
	var tenantName = params.tenant_name;


	var appState = new AppState();
	can.route.map(appState);

	can.route.ready();

	appState.attr({
		hubId : hubId,
		tenant : tenantName
	});

	//bindModelEvents(appState);

	$('body').addClass('no-background');

	$('#app').html(embedView({
		state: appState
	}))
});