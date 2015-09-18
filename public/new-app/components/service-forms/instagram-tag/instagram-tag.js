import can from "can/";
import initView from './instagram-tag.stache!';
import './instagram-tag.less!';

can.Component.extend({
	tag : 'bh-instagram-tag-service',
	template : initView
});
