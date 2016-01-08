/* global confirm:true */

import can from "can/";
import initView from "./hub-list.stache!";
import Models from "models/";
import _map from "lodash-amd/modern/collection/map";
import _reduce from "lodash-amd/modern/collection/reduce";

import "style/";
import "./hub-list.less!";
import "can/map/define/";
import "components/service-config-formatter/";


can.Component.extend({
	tag : 'bh-hub-list',
	template : initView,
	scope : {
		define : {
			expandedRows : {
				Value : Array
			}
		},
		init : function(){
			this.attr('hubs', new Models.Hub.List({}));
		},
		createAndEditHub : function(){
			new Models.Hub({
				name: ''
			}).save(function(hub){
				can.route.attr({
					hubId : hub.id,
					page : 'sidebar',
					panel : 'services'
				});
			});
		},
		destroyHub : function(hub){
			if(confirm('Are you sure?')){
				hub.destroy();
			}
		},
		toggleExpandedRow : function(hub){
			var hubId = hub.attr('id'),
					expandedRows = this.attr('expandedRows'),
					index = expandedRows.indexOf(hubId);

			if(index === -1){
				expandedRows.push(hubId);
			} else {
				expandedRows.splice(index, 1);
			}
		}
	},
	helpers : {
		isExpandedRow : function(hub, opts){
			var index;

			hub = can.isFunction(hub) ? hub() : hub;
			index = this.attr('expandedRows').indexOf(hub.attr('id'));
			
			return index > -1 ? opts.fn() : opts.inverse();
		},
		formatConnectedServices : function(services){
			var serviceNames;
			services = can.isFunction(services) ? services() : services;

			if(!services || services.isPending()){
				return;
			}

			serviceNames = can.map(services, function(service){
				return service.printFeed();
			});

			return _map(_reduce(serviceNames, function(acc, service){
				if(acc[service]){
					acc[service] += 1;
				} else {
					acc[service] = 1;
				}
				return acc;
			}, {}), function(occurenceCount, service){
				if(occurenceCount > 1){
					return service + ' (' + occurenceCount + ')';
				}
				return service;
			}).join(', ');
		}
	}
});

