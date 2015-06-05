import can from "can/";
import initView from "./moderation-rules.stache!";
import Models from "models/";
import "./moderation-rules.less!";

var TITLES = {
	approve : "<b>Automatically approve items</b> matching the following rules:",
	block   : "<b>Automatically block items</b> matching the following rules"
};

var VERBS = {
	"pos:contains_all"    : "Contains all words",
  "pos:contains_any"    : "Contains any",
	"pos:contains_phrase" : "Contains a phrase",
  "pos:is"              : "Is equal to",
  "neg:is"              : "Isn't equal to",
	"pos:starts_with"     : "Starts with",
	"neg:starts_with"     : "Doesn't start with",
	"pos:ends_with"       : "Ends with",
	"neg:ends_with"       : "Doesn't end with"
};

var FILTERS = {
	content   : "Content",
	title     : "Title",
	author    : "Author",
	feed_name : "Feed"
};

var FILTER_VERBS = {
	feed_name : ['pos:is', 'neg:is']
};

can.Component.extend({
	tag : 'bh-moderation-rules',
	template : initView,
	scope: {
		addFilter : function(){
			this.attr('filters').addFilter(this.attr('hub.id'));
		},
		title : function(){
			return TITLES[this.attr('filters.action')];
		},
		availableFilters : FILTERS,
		filtersNotMarkedForDelete : function(){
			var filters = this.attr('filters');
			filters.attr('length');
			return can.grep(filters, function(f){
				return !f.attr('__shouldDelete');
			});
		},
		feeds : Models.Service.feeds
	},
	events : {
		"[can-click=addFilter],[can-click=markToDestroy] click" : function(el, ev){
			ev.preventDefault();
		}
	},
	helpers : {
		templateIs : function(template, query, opts){
			var templateShouldBe = 'textarea';
			template = can.isFunction(template) ? template() : template;
			query = can.isFunction(query) ? query() : query;

			if(query.attr('op') === 'is' || query.attr('op') === 'contains_phrase'){
				templateShouldBe = 'input';
			}

			if(query.attr('attr_name') === 'feed_name'){
				templateShouldBe = 'feed_select';
			}

			if(template === templateShouldBe){
				return opts.fn();
			}
		},
		verbsForQuery : function(query, opts){
			var attr_name = query.attr('attr_name');
			var verbs = VERBS;
			var verbsSubset = FILTER_VERBS[attr_name];
			var html = [];

			query = can.isFunction(query) ? query() : query;
			
			if(verbsSubset){
				verbs = {};
				for(var i = 0; i < verbsSubset.length; i++){
					verbs[verbsSubset[i]] = VERBS[verbsSubset[i]];
				}
			}

			for(var k in verbs){
				if(verbs.hasOwnProperty(k)){
					html.push(opts.fn(opts.scope.add({filter: k, name: verbs[k]})));
				}
			}
			return html;
		}
	}
});
