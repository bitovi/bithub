import can from "can";
import initView from "./layout.stache!";

import HubModel from "models/hub";

import "./layout.less!";
import "components/edit_hub_name/";
import "components/empty-slate/";
import "bit-tabs/";
import "components/services/";

export default can.Component.extend({
	tag : 'bh-layout',
	template: initView,
	scope : {
		showServicesPanel: false,
		init(){
			this.attr('hub', new HubModel({name: "outrageous-darkness-1337"}));
		},
		toggleServicesPanel(){
			this.attr('showServicesPanel', !this.attr('showServicesPanel'));
		}
	}
});
