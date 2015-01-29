steal(
'can/model',
function(Model, ServiceModel){
	return Model.extend({
		findOne : '/api/v3/brands/current'
	}, {

	});
});
