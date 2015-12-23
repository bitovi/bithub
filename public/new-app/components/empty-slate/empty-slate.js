import can from "can";
import initView from "./empty-slate.stache!";
import "./empty-slate.less!";

export default can.Component.extend({
	tag: 'bh-empty-slate',
	template: initView
});
