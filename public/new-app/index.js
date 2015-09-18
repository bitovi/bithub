import $ from "jquery";
import can from "can";

import "bootstrap/less/bootstrap.less!";
import "style/style.less!";

import "components/layout/";

$('#app').html(can.stache('<bh-layout></bh-layout>')());
