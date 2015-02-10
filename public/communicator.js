steal('can/control', function(Control){
	return Control.extend({
		bind : function(frame){
			return new this(document.documentElement, {frame: frame});
		}
	},{
		init : function(){

		},
		'{window} message' : function(){
			console.log('MESSAGE', arguments)
		}
	})
});