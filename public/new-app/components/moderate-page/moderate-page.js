import can from "can";
import initView from "./moderate-page.stache!";

import "./moderate-page.less!";
import "components/empty-slate/";
import "components/admin-embed/";
import "components/moderation/";

export default can.Component.extend({
	tag: 'bh-moderate-page',
	template: initView,
	scope : {
		hasContent(){
			return true;
		}
	}
});
