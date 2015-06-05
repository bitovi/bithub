import can from "can/";
import initView from './twitter-followers.stache!';
import './twitter-followers.less!';

can.Component.extend({
	tag : 'bh-twitter-followers-service',
	template : initView
});
