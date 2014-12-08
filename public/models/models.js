steal('./hub.js', './service.js', './bit.js', function(Hub, Service, Bit){
	return {
		Hub : Hub,
		Service : Service,
		Bit : Bit
	}
})