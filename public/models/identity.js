steal('can/model', 'can/list/promise', function(Model){

	var identities;

	var Identity = Model.extend({
		resource : '/api/v3/identities',
		getAll : function(){
			return this.reloadAll();
			if(identities){
				return identities;
			}
			
		},
		reloadAll : function(){
			var def = new this.List({});

			def.then(function(data){
				identities = data;
			});

			return def;
		}
	}, {

	});

	Identity.List = Identity.List.extend({
		
	});

	return Identity;
})

