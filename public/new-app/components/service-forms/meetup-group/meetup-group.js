import can from "can";
import initView from './meetup-group.stache!';
import './meetup-group.less!';
import "components/suggestions/";

can.Component.extend({
	tag : 'bh-meetup-group-service',
	template : initView
});
