steal('can/util/fixture', './services.js', function(fixture){

	var embedStore = can.fixture.store(10, function(i){
		var id = i + 1;
		return {
			id: id,
			name: 'Hub ' + id,
			colorscheme : i % 2 === 0 ? 'dark' : 'light',
			layout : i % 3 === 0 ? 'list' : 'card',
			services : [{
				id: 1 + "" + id,
				feed_name: 'Twitter'
			},{
				id: 2 + "" + id,
				feed_name: 'Twitter'
			},{
				id: 3 + "" + id,
				feed_name: 'Facebook'
			},{
				id: 4 + "" + id,
				feed_name: 'Tumblr'
			},{
				id: 5 + "" + id,
				feed_name: 'Instagram'
			}]
		}
	});

	can.fixture('GET /api/v3/embeds', embedStore.findAll);
	can.fixture('GET /api/v3/embeds/{id}', embedStore.findOne);
	can.fixture('POST /api/v3/embeds', embedStore.create);
	can.fixture('PUT /api/v3/embeds/{id}', embedStore.update);
	can.fixture('DELETE /api/v3/embeds/{id}', embedStore.destroy);


})