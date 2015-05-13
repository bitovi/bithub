steal(
'./hub.js',
'./service.js',
'./bit.js',
'./identity.js',
'./suggestion.js',
'./brand.js',
'./preset.js',
'./analytics.js',
'./subscription.js',
'./filter.js',
'./account.js',
function(Hub, Service, Bit, Identity, Suggestion, Brand, Preset, Analytics, Subscription, Filter, Account){
	return {
		Hub : Hub,
		Service : Service,
		Bit : Bit,
		Identity : Identity,
		Suggestion : Suggestion,
		Brand : Brand,
		Preset: Preset,
		Analytics : Analytics,
		Subscription : Subscription,
		Filter : Filter,
		Account : Account
	}
})
