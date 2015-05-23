import can from "can/";
import initView from './tumblr-blog.stache!';
import './tumblr-blog.less!';

can.Component.extend({
	tag : 'bh-tumblr-blog-service',
	template : initView
});
