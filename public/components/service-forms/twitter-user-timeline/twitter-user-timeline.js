import can from "can/";
import initView from './twitter-user-timeline.stache!';
import './twitter-user-timeline.less!';

can.Component.extend({
	tag : 'bh-twitter-user-timeline-service',
	template : initView
});
