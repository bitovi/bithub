import can from "can";
import initView from "./publish-page.stache!";

import "./publish-page.less!";
import "components/empty-slate/";

export default can.Component.extend({
	tag: 'bh-publish-page',
	template: initView
});
