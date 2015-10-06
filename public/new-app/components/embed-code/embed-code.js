import can from "can";
import initView from "./embed-code.stache!";

import "./embed-code.less!";
import "components/embed-publish/";

export default can.Component.extend({
	tag : 'bh-embed-code',
	template: initView,
	scope : {
		isCCOpen : false,
		closeCC : function(ctx, el, ev){
			if($(ev.target).is('.cc-wrap')){
				this.attr('isCCOpen', false);
			}
		},
		openCC : function(){
			this.attr('isCCOpen', true);
		},
		presetEmbedCode : function(){
			var tenantName = this.attr('appState.currentBrand.tenant_name');
			var hub = this.attr('appState.currentHub');
			var hubId = hub.attr('id');
			var hubName = hub.attr('name');
			return this.attr('preset').embedCode(tenantName, hubId, hubName);
		}
	}
});
