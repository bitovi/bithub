import can from "can/";
import initView from './foursquare-venue.stache!';
import './foursquare-venue.less!';

can.Component.extend({
  tag : 'bh-foursquare-venue-service',
  template : initView
});
