steal('can/model', 'can/list/promise', function(Model){

	var identities;

	var Identity = Model.extend({
		resource : 'api/v3/identities',
		getAll : function(){
			if(identities){
				return identities;
			}
			return this.reloadAll();
		},
		reloadAll : function(){
			return new this.List({});

			def.then(function(data){
				identities = data;
			});

			return def;
		}
	}, {

	});

	Identity.List = Identity.List.extend({
		hasIdentityForService : function(service){
			var length = this.attr('length');
			for(var i = 0; i < length; i++){
				if(this.attr(i + '.provider') === service){
					return true;
				}
			}
			return false;
		}
	});

	return Identity;
})

