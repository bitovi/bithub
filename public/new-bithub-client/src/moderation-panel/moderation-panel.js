import can from "can";
import template from "./moderation-panel.stache!";

import "./moderation-panel.less!";

export default can.Component.extend({
	tag: 'bh-moderation-panel',
	template: template
});
