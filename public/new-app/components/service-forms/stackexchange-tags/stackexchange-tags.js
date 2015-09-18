import can from "can/";
import initView from './stackexchange-tags.stache!';
import './stackexchange-tags.less!';
import'components/tag-list/';

can.Component.extend({
	tag : 'bh-stackexchange-tags-service',
	template : initView,
});
