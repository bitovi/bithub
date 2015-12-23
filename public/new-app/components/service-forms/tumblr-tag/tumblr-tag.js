import can from "can";
import initView from './tumblr-tag.stache!';
import './tumblr-tag.less!';

can.Component.extend({
	tag : 'bh-tumblr-tag-service',
	template : initView
});
