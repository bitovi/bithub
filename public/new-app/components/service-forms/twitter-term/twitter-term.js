import can from "can";
import initView from './twitter-term.stache!';
import './twitter-term.less!';

can.Component.extend({
	tag : 'bh-twitter-term-service',
	template : initView
});
