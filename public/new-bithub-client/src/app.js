/* globals process */
/* globals global */
/* globals setTimeout */

import AppMap from "can-ssr/app-map";
import 'can/map/define/';
import 'can/route/pushstate/';
import Account from 'src/models/account';
import Hub from 'src/models/hub';
import Organization from 'src/models/organization';
import Bit from 'src/models/bit';
import EntityDecision from 'src/models/entity-decision';
import Service from 'src/models/service';
import $ from "jquery";
import Cookie from "js-cookie";
import connectLiveService from "./connect-liveservice";

can.route.bindings.pushstate.root = "/new-bithub/";
can.baseURL = '/new-bithub/';

var NODE_ENV = "";
var BITHUB_HOST = "http://dev.bithub.com";

if(process){
	NODE_ENV = (process.env && process.env.NODE_ENV) || "";
	BITHUB_HOST = (process.env && process.env.BITHUB_HOST) || BITHUB_HOST;
	
	console.log('BITHUB_HOST', BITHUB_HOST)

}

if(NODE_ENV.substr(0, 6) !== 'window'){
	// Hacking in session stuff (should be gone in next version)
	$.ajaxSettings.xhr = function(){
		try {
			var req = new global.XMLHttpRequest();
			var oldOpen = req.open;
			req.open = function(){
				if((arguments[1] || "").substr(0, 5) === '/api/'){
					arguments[1] = BITHUB_HOST + arguments[1];
				}
				var res = oldOpen.apply(this, arguments);

				console.log('AJAX CALL', global.__railsSessionId)

				if(this.setDisableHeaderCheck && global && global.__railsSessionId){
					this.setDisableHeaderCheck(true);
					this.setRequestHeader('Cookie', '_session_id=' + global.__railsSessionId);
				}
				
				return res;
			};
			return req;
		} catch( e ) {}
	};
}


const TAB_TO_FILTER = {
	pending: 'pending',
	approved: 'approved',
	starred: 'starred',
	deleted: 'deleted'
};

var getCurrentDecision = function(decisions, current){
	decisions = decisions || [];
	for(var i = 0; i < decisions.length; i++){
		if(decisions[i].id === current){
			return decisions[i];
		}
	}
};

const AppViewModel = AppMap.extend({
	define : {
		page : {
			set : function(val){
				return val;
			}
		},
		isSlideoutOpen : {
			serialize: false,
			value: false,
			set : function(val){
				if(val){
					this.attr('wasSlideoutOpen', true);
				}
				return val;
			}
		},
		wasSlideoutOpen : {
			value: false,
			serialize: false
		},
		tab : {
			get : function(lastSetVal){
				return lastSetVal || "pending";
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
		isChangingOrganization : {
			value: false,
			serialize: false
		},
		currentOrganizationId : {
			set : function(newVal, setVal){
				var self = this;
				if(newVal){
					Organization.choose(newVal).then(function(){
						self.attr('organizationsOpen', false);
						window.location.href = "/new-bithub/";
					});
				}
			},
			get : function(lastValue, setter){
				if(!lastValue){
					this.waitFor(Organization.current()).then(function(organization){
						setter(organization.id);
					});
				}
				return lastValue;
			}
		},
		currentOrganization: {
			serialize: false,
			get : function(lastValue, setter){
				var organizations = this.attr('currentAccount.organizations');
				var currentOrganizationId = parseInt(this.attr('currentOrganizationId'), 10);
				var length;
				if(organizations && currentOrganizationId){
					length = organizations.attr('length');
					for(var i = 0; i < length; i++){
						if(organizations[i].id === currentOrganizationId){
							return organizations[i];
						}
					}
				}
			}
		},
		currentHubIdAsString: {
			get: function(){
				return this.attr("currentHubId") ? ""+this.attr("currentHubId") : undefined;
			},
			set: function(newVal){
				this.attr("currentHubId", parseInt(newVal,10));
			},
			serialize: true,
		},
		currentHubId: {
			set: function(newVal, resolve){
				if(newVal){
					return newVal;
				}
			},
			get: function(lastSet, resolve){
				if(!lastSet && resolve) {
					Hub.findAll({limit: 1}).then((hubs) => {
						this.attr("currentHub",hubs[0] );
						resolve(hubs[0].attr("id"));
					});
				} else {
					return lastSet;
				}
			}
		},
		currentHub: {
			serialize: false,
			get : function(lastSetVal, setter){
				var currentHubId = this.attr('currentHubId');
				if(currentHubId) {
					if(lastSetVal && lastSetVal.attr("id") === currentHubId ) {
						return lastSetVal;
					} else {
						
						Hub.findOne({id: currentHubId}).then(setter);
						return null;
					}
				} else {
					return null;
				}
			}
		},
		hubs : {
			serialize: false,
			get : function(){
				return new Hub.List({});
			}
		},
		loadingServices : {
			serialize : false,
			get : function(){
				return [];
			}
		},
		title : {
			serialize : false,
			value : 'BitHub'
		},
		entityDecisions : {
			get : function(){
				var currentHub = this.attr('currentHub');
				var deferred, list;
				if(currentHub){
					deferred = can.Deferred();
					list = new EntityDecision.List({hubId: currentHub.id});
					this.waitFor(deferred);
					list.then(function(){
						deferred.resolve();
					}, function(){
						deferred.reject();
					});
					return list;
				}
			}
		},
		services : {
			get : function(){
				var currentHub = this.attr('currentHub');
				var deferred, list;
				if(currentHub){
					deferred = can.Deferred();
					list = new Service.List({embed_id: currentHub.id});
					this.waitFor(deferred);
					list.then(function(){
						deferred.resolve();
					}, function(){
						deferred.reject();
					});
					return list;
				}
			}
		},
		// Creates an empty list, returns it, but in next turn, 
		// calls `loadNextPage` to populate list.
		bits : {
			get : function(){
				var tab = this.attr('moderationTab');
				var currentHub = this.attr('currentHubId');
				var list = new Bit.List();
				var deferred = can.Deferred();
				var self = this;
				
				clearTimeout(this.__listRefreshTimeout);

				if(tab && currentHub){
					list.__loadingParams = {
						hubId: currentHub,
						decision: TAB_TO_FILTER[tab],
						limit: 50,
						offset: 0
					};
					setTimeout(function(){
						
						var req = list.loadNextPage();
						if(req){
							req.then(function(){
								self.refreshBits();
								deferred.resolve();
							});
						} else {
							deferred.resolve();
						}
					});
					//this.waitFor(deferred);
					return list;
				}
			}
		},
		organizationsOpen : {
			serialize: false,
			value: false
		}
	},
	init : function(){
		$("html").data("viewModel",this);
		var self = this;
		can.on.call(Bit, 'decision', this.handleDecision.bind(this));
		Account.current().then(function(acc){
			//console.log('ACCOUNT', acc);
			self.attr('currentAccount', acc);
		}, function(){
			//console.log('ACCOUNT REQ', arguments);
			window.location.href = "/";
		});
	},
	refreshBits : function(){
		var self = this;
		this.__listRefreshTimeout = setTimeout(function(){
			self.attr('bits').refresh(function(newCount){
				var currentDecision = getCurrentDecision(self.attr('entityDecisions'), self.attr('moderationTab'));
				if(currentDecision){
					currentDecision.attr('count', currentDecision.attr('count') + newCount);
				}
			});
			self.refreshBits();
		}, 30000);
	},
	toggleOrganizations: function(){
		this.attr('organizationsOpen', !this.attr('organizationsOpen'));
	},
	handleDecision: function(ev, oldDecision, newDecision){
		var entityDecisions = this.attr('entityDecisions');
		if(entityDecisions.isResolved()){
			can.batch.start();
			entityDecisions.getById(oldDecision).dec();
			entityDecisions.getById(newDecision).inc();
			can.batch.stop();
		}
	},
	isAdmin : function(){
		return true;
	},
	resetEmbed : function(){},
	changeCurrentOrganizationId : function(id){
		this.attr('currentOrganizationId', id);
	},
	isLoaded : function(){
		var services = this.attr('services');

		if(!this.attr('currentAccount')){
			return false;
		}
		if(this.attr('isChangingOrganization')){
			return false;
		}
		if(!services || (services && services.isPending())){
				return false;
		}
		return true;
	},
	redirectToDesktop : function(ctx, el, ev){
		ev.preventDefault();
		Cookie.set('redirected-from-new-ui', 1);
		window.location.href = el.attr('href');
	}
});

can.route("/:currentHubIdAsString", {page: 'moderation', moderationTab: 'pending'});
can.route('/:currentHubIdAsString/:page', {moderationTab: 'pending'});
can.route('/:currentHubIdAsString/:page/:moderationTab');

export default AppViewModel;
