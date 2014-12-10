steal('./hub.js', './service.js', './bit.js', './identity.js', function(Hub, Service, Bit, Identity){
	return {
		Hub : Hub,
		Service : Service,
		Bit : Bit,
		Identity : Identity
	}
})