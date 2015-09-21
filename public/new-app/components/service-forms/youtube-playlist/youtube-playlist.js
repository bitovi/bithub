import can from "can";
import initView from './youtube-playlist.stache!';
import './youtube-playlist.less!';

can.Component.extend({
	tag : 'bh-youtube-playlist-service',
	template : initView
});
