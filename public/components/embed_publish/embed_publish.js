/* globals Stripe:true*/
import can from "can/";
import initView from "./embed_publish.stache!";

import Preset from "models/preset";
import $ from "jquery";
import _some from "lodash/collection/some";

import "./embed_publish.less!";
import "components/integration/";
import "jquerypayment";
import "can/map/define/";

var CC = can.Map.extend({
	parsedExpiration(){
		return $.payment.cardExpiryVal(this.expiration || "");
	},
	month(){
		return this.parsedExpiration().month;
	},
	year(){
		return this.parsedExpiration().year;
	},
	numberNumberWithoutSpaces(){
		return (this.number || "").replace(/[^0-9]/g, "");
	}
});

var EmbedPublishVM = can.Map.extend({
	isSaving: false,
	init(){
		this.attr({
			cc : new CC(),
			errors : null
		});
	},
	showCCForm(){
		return !this.attr('state.currentSubscription').hasCC() || this.attr('changeCC');
	},
	validate(){
		var cc = this.attr('cc');
		var expiration = $.payment.cardExpiryVal(cc.expiration || "");
		var errors = {};
		var cardType = $.payment.cardType(cc.number || "");

		errors.number = !$.payment.validateCardNumber(cc.number || "");
		errors.expiration = !$.payment.validateCardExpiry(expiration.month, expiration.year);
		errors.cvc = !$.payment.validateCardCVC(cc.cvc || "", cardType);
		
		this.attr('errors', errors);
		return !_some(errors, function(val){
			return val;
		});
	},
	createSubscriptionAndPublishHub(){
		var self = this;
		var cc;
		if(this.validate()){
			this.attr('isSaving', true);
			cc = this.attr('cc');
			Stripe.card.createToken({
				number: cc.numberNumberWithoutSpaces(),
				cvc: cc.cvc,
				exp_month: cc.month(),
				exp_year: cc.year()
			}, function(){
				self.attr('isSaving', false);
				console.log(arguments);
			});
			// create token
			// publish
		}
	},
	embedUrl(){
		var state = this.attr('state');
		var currentBrand = state.attr('currentBrand');
		var hub = state.attr('hub');
		var preset = Preset.PREVIEW;
		
		return preset.fullUrl(currentBrand.attr('tenant_name'), hub.attr('id'));
	},
	toggleChangeCC(){
		var newState = !this.attr('changeCC');
		can.batch.start();
		if(newState){
			this.attr('cc', new CC());
		}
		this.attr('changeCC', newState);
		can.batch.stop();
	}
});

can.Component.extend({
	tag : "bh-embed-publish",
	template : initView,
	scope : EmbedPublishVM,
	helpers : {
		formatCC(format){
			format = can.isFunction(format) ? format() : format;
			return function(el){
				$(el).payment('format' + format);
			};
		}
	}
});
