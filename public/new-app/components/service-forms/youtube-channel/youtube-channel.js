import can from "can";
import initView from './youtube-channel.stache!';
import './youtube-channel.less!';

can.Component.extend({
	tag : 'bh-youtube-channel-service',
	template : initView
});
