import can from "can";
import initView from './twitter-user-retweets.stache!';
import './twitter-user-retweets.less!';

can.Component.extend({
	tag : 'bh-twitter-user-retweets-service',
	template : initView
});
