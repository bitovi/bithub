steal(
'can/model',
'./service.js',
'can/list/promise',
'can/construct/super',
'can/map/backup',
'can/map/define',
function(Model, ServiceModel){
	return Model.extend({
		resource : '/api/v3/embeds'
	}, {
		define : {
			services : {
				get : function(){
					return new ServiceModel.List({embed_id: this.attr('id')})
				}
			}
		},
		serialize : function(){
			return {
				embed : this._super.apply(this, arguments)
			}
		}
	});
});
