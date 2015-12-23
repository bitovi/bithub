import can from "can";
import initView from './github-repo.stache!';
import './github-repo.less!';

can.Component.extend({
	tag : 'bh-github-repo-service',
	template : initView
});
