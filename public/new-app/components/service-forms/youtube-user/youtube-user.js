import can from "can";
import initView from './youtube-user.stache!';
import './youtube-user.less!';

can.Component.extend({
	tag : 'bh-youtube-user-service',
	template : initView
});
