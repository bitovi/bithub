import can from "can";
import initView from "./disqus-forum.stache!";

import "./disqus-forum.less!";
import "components/suggestions/";

can.Component.extend({
	tag : 'bh-disqus-forum-service',
	template : initView
});
