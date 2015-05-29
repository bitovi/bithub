import can from "can/";
import initView from "./bit-list.stache!";
import Bit from "models/bit";
import InteractionEvent from "models/interaction_event";
import _map from "lodash/collections/map";

import "can/construct/super/";
import "can/construct/proxy/";
import "bit/";
import "bits_vertical_infinite/";


export default can.Control.extend({
	pluginName : 'bh-bits',
}, {
	setup : function(el, opts){
		opts = opts || {};
		opts.isLoading   = can.compute(false);
		opts.hasNextPage = can.compute(true);
		return this._super(el, opts);
	},
	init : function(){
		this.__timeouts = {};

		this.currentOffset = can.compute(0);
		this.bits = this.options.state.attr('bits');

		this.element.html(initView({
			isLoading : this.options.isLoading,
			state : this.options.state,
			bits: this.bits
		}));

		this.load();
	},
	load : function(cb){
		var self = this;
		this.options.isLoading(true);


		this.__pendingReq = Bit.findAll(this.options.state.getParams()).then(function(data){

			can.batch.start();

			self.options.isLoading(false);

			if(data.length < self.options.state.attr('params.limit')){
				self.options.hasNextPage(false);
			}

			self.currentLimit = self.currentLimit + data.length;

			delete self.__pendingReq;

			self.bits.push.apply(self.bits, data);
			self.currentOffset(self.currentOffset() + data.length);

			can.batch.stop();
		});
	},
	"bits:nextPage" : function(el, ev){
		var params;
		if(this.options.isLoading() || !this.options.hasNextPage()){
			return;
		}
		params = this.options.state.attr('params');
		params.attr('offset', this.currentOffset());
		
		this.load();
	},
	destroy : function(){
		if(this.__pendingReq){
			this.__pendingReq.abort();
		}
		return this._super.apply(this, arguments);
	},
	'interaction:scroll' : function(el, ev, hubId){
		if(!this.__savedScrollInteraction){
			InteractionEvent.createScrollInteraction(hubId);
			this.__savedScrollInteraction = true;
		}
	},
	'interaction:link' : function(el, ev, hubId, entityId){
		if(!this.options.state.isAdmin()){
			InteractionEvent.createLinkClickedInteraction(hubId, entityId);
		}
	},
	'interaction:share' : function(el, ev, hubId, entityId, target){
		if(!this.options.state.isAdmin()){
			InteractionEvent.createEntitySharedInteraction(hubId, entityId, target);
		}
	}
});
