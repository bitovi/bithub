import "can/view/autorender/";
import "bootstrap/less/bootstrap.less!";
import "style/style.less!";
import "components/layout/";
import $ from "jquery";

$.ajaxPrefilter(function( options, originalOptions, jqXHR ) {
	if(options.type.toLowerCase() !== 'get'){
		options.data = JSON.stringify(originalOptions.data);
		options.contentType = 'application/json';
	}
});
