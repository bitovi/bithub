import can from "can/";
import initView from "./payments.stache!";

import "style/";
import "./payments.less!";
import "can/map/define/";


can.Component.extend({
	tag : 'bh-payments',
	template : initView,
	scope : {
		init : function(){
			
		},
		billingInfoUrl : "/admin/subscriptions/edit/cc",
		accountPlanUrl : "/admin/subscriptions/edit/plan",
		planPrice : function(){
			var price = this.attr('state.currentSubscription.plan.amount');
			if(!price){
				return;
			}
			price = price + "";
			return "$" + price.slice(0, -2) + "." + price.slice(-2);
		},
		openBillingInfo : function(){
			this.attr('currentIframe', this.attr('billingInfoUrl'));
		},
		openAccountPlan : function(){
			this.attr('currentIframe', this.attr('accountPlanUrl'));
		},
		closeIframe : function(){
			this.attr('currentIframe', null);
		}
	},
	events : {
		".overlay click" : function(el, ev){
			this.scope.closeIframe();
		}
	}
});

