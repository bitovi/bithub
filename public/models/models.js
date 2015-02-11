steal(
'./hub.js',
'./service.js',
'./bit.js',
'./identity.js',
'./suggestion.js',
'./brand.js',
'./preset.js',
function(Hub, Service, Bit, Identity, Suggestion, Brand, Preset){
	return {
		Hub : Hub,
		Service : Service,
		Bit : Bit,
		Identity : Identity,
		Suggestion : Suggestion,
		Brand : Brand,
		Preset: Preset
	}
})