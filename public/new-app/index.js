import $ from "jquery";
import can from "can";
import Models from "models/";
import route from "can/route/";

import "bootstrap/less/bootstrap.less!";
import "style/style.less!";
import "can/map/define/";
import "components/layout/";


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
		}
	}
});


$.when(
	Models.Brand.findOne({}),
	Models.Subscription.findOne({}),
	Models.Account.current(),
	Models.Organization.current(),
	Models.Hub.findAll({})
).done(function(brand, subscription, account, organization, hubs){
		
	var appState = new AppState({
		currentBrand: brand,
		currentSubscription: subscription,
		currentAccount: account,
		currentOrganization: organization,
		hubs: hubs,
		currentHub: hubs[0],
	});
	
	


	route.map(appState);
	route("", {page: "moderation"});
	route.ready();
	


	$('#app').html(can.stache('{{#appState.currentHub}}<bh-layout app-state="{appState}"></bh-layout>{{/appState.currentHub}}')({
		appState: appState
	}));
});
