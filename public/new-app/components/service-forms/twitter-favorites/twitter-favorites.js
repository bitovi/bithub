import can from "can";
import initView from './twitter-favorites.stache!';
import './twitter-favorites.less!';

can.Component.extend({
	tag : 'bh-twitter-favorites-service',
	template : initView
});
