steal('can/model', 'can/list/promise', 'can/construct/super', 'can/map/backup', function(Model){
	return Model.extend({
		resource : '/api/v3/embeds'
	}, {
		serialize : function(){
			return {
				embed : this._super.apply(this, arguments)
			}
		}
	});
});
