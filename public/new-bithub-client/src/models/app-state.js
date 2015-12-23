import $ from "jquery";
import can from "can";
import Models from "models/";
import route from "can/route/";

import "can/map/define/";


var AppState = can.Map.extend({
	define : {
		page : {
			set : function(val){
				return val;
			}
		},
		tab : {
			get : function(lastSetVal){
				return lastSetVal || "inbox";
			}
		},
		currentBrand : {
			serialize: false
		},
		currentSubscription : {
			serialize: false
		},
		currentAccount : {
			serialize: false
		},
		currentOrganization: {
			serialize: false
		},
		currentHub: {
			serialize: false,
		},
		hubs : {
			serialize: false
		},
		loadingServices : {
			serialize : false,
			get : function(){
				return [];
			}
		},
	
	},
	isAdmin : function(){
		return true;
	},
	resetEmbed : function(){}
});

var appState = new AppState();
route.map(appState);
route("", {page: "moderation"});
route.ready();


$.when(
	Models.Brand.findOne({}),
	Models.Subscription.findOne({}),
	Models.Account.current(),
	Models.Organization.current(),
	Models.Hub.findAll({})
).done(function(brand, subscription, account, organization, hubs){
		
	appState.attr({
		currentBrand: brand,
		currentSubscription: subscription,
		currentAccount: account,
		currentOrganization: organization,
		hubs: hubs,
		currentHub: hubs[0],
	});

});

export default appState;
