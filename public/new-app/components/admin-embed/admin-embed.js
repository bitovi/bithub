import can from "can";
import initView from "./admin-embed.stache!";
import "./admin-embed.less!";

import Bit from "models/bit";
import Preset from "models/preset";
import "can/map/define/";
import "components/bit/";
import $ from "jquery";
import iframe from "iframe-resizer/js/index";


export default can.Component.extend({
	tag : 'bh-admin-embed',
	template: initView,
	scope : {
		define : {
			iframe : {
				get : function(){
					var src = this.attr('iframeSrc');
					var iframe;

					if(src){
						iframe = $('<iframe src="' + src + '"></iframe>');
						setTimeout(function(){
							iframe.iFrameResize({heightCalculationMethod: 'lowestElement'});
						}, 1);
						return iframe[0];
					}
				}
			},
			iframeSrc : {
				get : function(){
					var currentBrand = this.attr('appState.currentBrand');
					var hubId = this.attr('appState.currentHub.id');

					if(hubId && currentBrand){
						return Preset.ADMIN.url(currentBrand.attr('tenant_name'), hubId);
					}
				},
				serialize: false
			},
		},
		init : function(){
			var self = this;
		}
	}
});
