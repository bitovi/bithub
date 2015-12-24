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

can.route.bindings.pushstate.root = "/new-bithub/";
can.baseURL = '/new-bithub/';

var NODE_ENV = "";
var BITHUB_HOST = "http://dev.bithub.com";

if(process){
	NODE_ENV = (process.env && process.env.NODE_ENV) || "";
	BITHUB_HOST = (process.env && process.env.BITHUB_HOST) || BITHUB_HOST;
}

if(NODE_ENV.substr(0, 6) !== 'window'){
	$.ajaxSettings.xhr = function(){
		try {
			var req = new global.XMLHttpRequest();
			var oldOpen = req.open;
			req.open = function(){
				if((arguments[1] || "").substr(0, 5) === '/api/'){
					arguments[1] = BITHUB_HOST + arguments[1];
				}
				var res = oldOpen.apply(this, arguments);
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

const AppViewModel = AppMap.extend({
	define : {
		page : {
			set : function(val){
				return val;
			}
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
			serialize: false,
			get : function(lastValue, setter){
				if(!lastValue){
					return this.waitFor(Account.current()).then(function(account){
						setter(account);
					}, function(){
						console.log('NO CURRENT ACCOUNT');
						window.location.href = "/";
					});
				}
				return lastValue;
			}
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
		currentHubId : {
			set : function(newVal, setVal){
				if(newVal){
					return newVal;
				}
			}
		},
		currentHub: {
			serialize: false,
			get : function(){
				var hubs = this.attr('hubs');
				var length = hubs.attr('length');
				var currentHubId = parseInt(this.attr('currentHubId'), 10);
				if(hubs.isResolved()){
					for(var i = 0; i < length; i++){
						if(hubs[i].id === currentHubId){
							return hubs[i];
						}
					}
				}
			}
		},
		hubs : {
			serialize: false,
			get : function(){
				var self = this;
				var hubList = new Hub.List({});
				var deferred = can.Deferred();
				hubList.then(function(hubs){
					if(!self.attr('currentHubId') && hubs.length){
						self.attr('currentHubId', hubs[0].id);
					}
					setTimeout(function(){
						deferred.resolve();
					}, 1);
				}, function(e){
					deferred.reject();
				});
				this.waitFor(deferred);
				return hubList;
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
					});
					return list;
				}
			}
		},
		bits : {
			get : function(){
				var tab = this.attr('moderationTab');
				var currentHub = this.attr('currentHubId');
				var list = new Bit.List();
				var deferred = can.Deferred();
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
		can.on.call(Bit, 'decision', this.handleDecision.bind(this));
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
		if(this.attr('isChangingOrganization')){
			return false;
		}
		if(this.attr('hubs').isResolved()){
			if(this.attr('hubs.length') === 0){
				return true;
			}
			if(this.attr('services') && this.attr('services').isResolved() && this.attr('currentHub')){
				return true;
			}
		}
		return false;
	},
	redirectToDesktop : function(ctx, el, ev){
		ev.preventDefault();
		Cookie.set('redirected-from-new-ui', 1);
		window.location.href = el.attr('href');
	}
});

can.route("/:currentHubId", {page: 'moderation', moderationTab: 'pending'});
can.route('/:currentHubId/:page', {moderationTab: 'pending'});
can.route('/:currentHubId/:page/:moderationTab');

export default AppViewModel;
