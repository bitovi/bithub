import AppState from 'models/embed_appstate';
import Bit from 'models/bit';
import Hub from 'models/hub';
import BitList from 'bit-list/';
import Communicator from 'communicator/';
import 'can/route/';
import "style/embed.less!";
var params = can.deparam(window.location.search.substr(1));
var isLoadedFromIframe = window.parent !== window;
var appState = new AppState();

var bodyClasses = [(isLoadedFromIframe ? 'iframe-context' : 'page-context'), 'embed'];

var triggerPartition = (function(){
	var partitionTimeout;
	return function(bits){
		clearTimeout(partitionTimeout);
		partitionTimeout = setTimeout(function(){
			can.trigger(bits, 'partition');
		}, 100);
	};
})();

var kickstart = function(hub){
	var communicator = Communicator.bind(window.parent, {
		updateAttrs : function(data){
			appState.setAttrs(data);
		},
		reset : function(){
			resetApp();
		}
	});

	bodyClasses.push((params.theme || 'light') + '-theme');

	//can.route.map(appState);
	//can.route.ready();


	appState.attr('hub', hub);
	appState.setAttrs(params);
	appState.connectLiveService();

	if(!appState.isPublic()){
		bodyClasses.push('admin-embed');
	}

	Bit.on('lifecycle', function(ev, bit){
		var serviceIds = bit.attr('service_ids');
		var bits = appState.attr('bits');
		var isLive = appState.isLive();

		if(appState.isPublic() && isLive && bit.isPublic()){
			bits.place(bit);
		} else {
			if(isLive && bits.indexOf(bit) === -1 && bit.attr('decision') === appState.attr('decision')){
				bits.unshift(bit);
			}
		}

		triggerPartition(bits);

		if( serviceIds && (params.view !== 'public') ){
			communicator.send('loadedBits', serviceIds);
		}

	});

	Bit.on('disapproved', function(ev, bit){
		var bits = appState.attr('bits');
		var index = bits.indexOf(bit);
		if(appState.isPublic() && index > -1){
			bits.splice(index, 1);
		}
	});

	$('body').addClass(bodyClasses.join(' '));

	var initApp = function(){
		var div = $('<div id="app" />');

		$('#app-wrapper').html(div);
		console.log('INIT APP')
		new BitList(div, {
			state : appState
		});
	};

	var resetApp = (function(){
		var timeout;
		return function(){
			clearTimeout(timeout);
			setTimeout(function(){
				appState.reset();
				initApp();
			}, 1);
		};
	})();

	appState.on('view', resetApp);
	appState.on('order', resetApp);
	appState.on('decision', resetApp);
	appState.on('service_id', resetApp);
	appState.on('image_only', resetApp);

	appState.on('theme', function(ev, newTheme){
		$('body').removeClass('dark-theme light-theme').addClass(newTheme + '-theme');
	});

	initApp();
};

Hub.findOne({id: params.hubId}).then(function(hub){
	kickstart(hub);
}, function(){
	kickstart();
});
