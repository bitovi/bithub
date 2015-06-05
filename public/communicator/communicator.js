/* global EMBED_ENDPOINT:true */
import can from "can/";

var preparePayload = function(payload){
	while(payload && can.isFunction(payload.attr)){
		payload = payload.attr();
	}
	return payload;
};

export default can.Control.extend({
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
				this.options.handlers[type](event.data.payload);
			}
		}
	},
	send : function(type, payload){
		var frame = this.options.frame;

		frame = can.isFunction(frame) ? frame() : frame;

		frame = frame.contentWindow ? frame.contentWindow : frame;

		if(frame && frame.postMessage){
			try {
				frame.postMessage({
					type: type,
					payload: preparePayload(payload)
				}, 'http://' + EMBED_ENDPOINT);
			} catch (e) {
				console.log( e );
			}
		}
	},
	'{window} message' : 'receive'
});
