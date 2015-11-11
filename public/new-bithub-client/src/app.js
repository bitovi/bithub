import AppMap from "can-ssr/app-map";
import 'can/map/define/';
import 'can/route/pushstate/';
import Account from 'src/models/account';
import Hub from 'src/models/hub';
import Organization from 'src/models/organization';
import Bit from 'src/models/bit';
import EntityDecision from 'src/models/entity-decision';

can.route.bindings.pushstate.root = "/new-bithub/";

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
					Account.current().then(function(account){
						setter(account);
					});
				} else {
					return lastValue;
				}
			}
		},
		currentOrganizationId : {
			set : function(newVal, setVal){
				if(newVal){
					setVal(newVal);
				}
			},
			get : function(lastValue, setter){
				if(!lastValue){
					Organization.current().then(function(organization){
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
					setVal(newVal);
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
				hubList.then(function(hubs){
					if(!self.attr('currentHubId') && hubs.length){
						self.attr('currentHubId', hubs[0].id);
					}
				});
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
				if(currentHub){
					return new EntityDecision.List({hubId: currentHub.id});
				}
			}
		},
		bits : {
			get : function(){
				var tab = this.attr('moderationTab');
				var currentHub = this.attr('currentHubId');
				if(tab && currentHub){
					return new Bit.List({hubId: currentHub, decision: TAB_TO_FILTER[tab]});
				}
			}
		}
	},
	init : function(){
		can.on.call(Bit, 'decision', this.handleDecision.bind(this));
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
	isLoaded : function(){
		return this.attr('hubs').isResolved() && this.attr('currentHub');
	}
});



can.route("/:currentHubId", {page: 'moderation', moderationTab: 'pending'});
can.route('/:currentHubId/:page', {moderationTab: 'pending'});
can.route('/:currentHubId/:page/:moderationTab');

export default AppViewModel;
