import can from "can/";
import initView from './twitter-hashtag.stache!';
import './twitter-hashtag.less!';

can.Component.extend({
	tag : 'bh-twitter-hashtag-service',
	template : initView
});
