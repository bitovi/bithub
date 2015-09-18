import can from "can/";
import initView from './facebook-public-page.stache!';
import './facebook-public-page.less!';
import 'components/suggestions/';


can.Component.extend({
	tag : 'bh-facebook-public-page-service',
	template : initView,
	scope : {
		loading: "",
		loadedPage: null,
		error: "",
		init : function(){
			
		}
	}
});
