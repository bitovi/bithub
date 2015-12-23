import can from "can";
import initView from "./layout.stache!";

import appState from "models/app-state";
import HubModel from "models/hub";

import "./layout.less!";
import "components/edit_hub_name/";
import "components/empty-slate/";
import "bit-tabs/";
import "components/helpers";

export default can.Component.extend({
	tag : 'bh-layout',
	template: initView,
	scope : {
		showServicesPanel: false,
		init(){
			this.attr('appState', appState);
		},
		toggleServicesPanel(){
			this.attr('showServicesPanel', !this.attr('showServicesPanel'));
		},
		selectOrganization(ctx, el, ev){
			var val = el.val();
			if(val){
				this.attr('appState').attr('currentOrganization', ctx);
			}
		},
		selectHub(ctx, el, ev){
			var val = el.val();
			var newHub;
			if(val){
				newHub = this.attr('appState.hubs').filter(function(hub){
					return hub.attr('id') ===  parseInt(val, 10);
				})[0];



				this.attr('appState').attr('currentHub', newHub);
			}
		},
	}
});
