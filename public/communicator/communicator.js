steal('can/control', function(Control){
	return Control.extend({
		bind : function(frame, handlers){
			return new this(document.documentElement, {
				frame: frame,
				handlers : handlers || {}
			});
		}
	},{
		receive : function(el, ev){
			var event = ev.originalEvent;
			var type = event.data.type;
			if(event.origin !== 'http://' + EMBED_ENDPOINT){
				return;
			} else {
				if(this.options.handlers[type]){
					this.options.handlers[type](event.data.payload)
				}
			}
		},
		'{window} message' : 'receive'
	})
});