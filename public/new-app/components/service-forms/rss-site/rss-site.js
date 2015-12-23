import can from "can";
import initView from './rss-site.stache!';
import './rss-site.less!';

can.Component.extend({
	tag : 'bh-rss-site-service',
	template : initView
});
