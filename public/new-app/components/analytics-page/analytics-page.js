import can from "can";
import initView from "./analytics-page.stache!";

import "./analytics-page.less!";
import "components/empty-slate/";

export default can.Component.extend({
	tag: 'bh-analytics-page',
	template: initView
});
