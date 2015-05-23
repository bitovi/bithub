import can from "can/";

import initView from './facebook-page.stache!';
import './facebook-page.less!';
import 'components/suggestions/';

can.Component.extend({
  tag : 'bh-facebook-page-service',
  template : initView
});
