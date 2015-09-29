import can from "can";
import initView from "./embed-code.stache!";

import "./embed-code.less!";
import "components/embed-publish/";

export default can.Component.extend({
	tag : 'bh-embed-code',
	template: initView
});
