import $ from "jquery";
import can from "can";

import route from "can/route/";

import "bootstrap/less/bootstrap.less!";
import "style/style.less!";

import "components/layout/";


var AppState = can.Map.extend({});
var appState = new AppState();

route.map(appState);
route("", {page: "moderation"});
route.ready();

$('#app').html(can.stache('<bh-layout state="{state}"></bh-layout>')({state: appState}));
