steal(
'can/map',
'./bithub-social.stache!',
'can/route',
'can/view/stache',
'can/map/define',
'components',
'fixtures',
function(Map, initView, route, stache){

	var AppState = Map.extend({
		define : {
			page : {
				value : 'hub-list'
			}
		},
		isSidebar : function(){
			return this.attr('page') === 'sidebar'
		}
	})

	var appState = new AppState;

	can.route.map(appState);

	can.route.ready();

	stache.registerHelper('pageUrl', function(page, title){
		page = can.isFunction(page) ? page() : page;

		return can.route.url({page: page}, false);
	});

	$('#app').html(initView({
		state: appState
	}, {
		renderPage : function(){
			var page = can.route.attr('page'),
				template = can.stache('<bh-' + page + ' state="{state}"></bh-' + page + '>');

			return template(this)
		},
		pageLink : function(page, title){
			page = can.isFunction(page) ? page() : page;
			title = can.isFunction(title) ? title() : title;

			var currentPage = can.route.attr('page'),
				props = {
					'class' : 'btn '
				};

			props['class'] += page === currentPage ? 'btn-default' : 'btn-link';

			return can.route.link(title, {page: page}, props, false);
		}
	}));

});