import can from "can/";
import initView from './github-org.stache!';
import './github-org.less!';

can.Component.extend({
	tag : 'bh-github-org-service',
	template : initView
});
