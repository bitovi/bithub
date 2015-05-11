steal(
'can/model',
function(Model){
	return Model.extend({
		findOne : '/api/v3/accounts/{id}',
		current : function(){
			return this.findOne({id: 'current'});
		}
	}, {

	});
});
