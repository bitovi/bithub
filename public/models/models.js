steal(
'./hub.js',
'./service.js',
'./bit.js',
'./identity.js',
'./suggestion.js',
function(Hub, Service, Bit, Identity, Suggestion){
	return {
		Hub : Hub,
		Service : Service,
		Bit : Bit,
		Identity : Identity,
		Suggestion : Suggestion
	}
})