steal(
'can/model',
function(Model){
	return Model.extend({
		findAll : '/api/v3/services/suggestions/{service}'
	}, {

	});
});