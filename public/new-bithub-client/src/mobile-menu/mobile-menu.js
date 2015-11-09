import can from "can";
import template from "./mobile-menu.stache!";

import "./mobile-menu.less!";

export default can.Component.extend({
	tag : 'bh-mobile-menu',
	template: template
});
