import can from "can";
import NatlangQuery from "./natlang-query";
import "can/map/define/";
import "can/construct/super/";

var ModerationRuleset = can.Model.extend({
	resource : "/api/v3/filters",
	destroy : function(id, data){
		return $.ajax({
			url : "/api/v3/filters/" + id + "?embed_id=" + data.filter.embed_id,
			type : "DELETE"
		});
	}
}, {
	define : {
		natlang_queries: {
			Value : NatlangQuery.List,
			set : function(val){
				return new NatlangQuery.List(can.map(val, function(v){
					return NatlangQuery.model(v);
				}));
			}
		},
	},
	addQuery : function(){
		this.natlang_queries.push(new NatlangQuery());
	},
	removeQuery : function(filter){
		var natlang = this.attr('natlang_queries');
		var index = natlang.indexOf(filter);
		if(index > -1){
			natlang.splice(index, 1);
		}
	},
	serialize : function(){
		var data = this._super.apply(this, arguments);
		return {
			filter: data
		};
	},
	markToDestroy : function(){
		this.attr('__shouldDelete', true);
	},
	saveOrDestroy : function(){
		if(this.attr('__shouldDelete')){
			return this.destroy();
		}
		return this.save();
	}
});

ModerationRuleset.List = ModerationRuleset.List.extend({
	blocking : function(){
		return this.filtersByAction('block');
	},
	approving : function(){
		return this.filtersByAction('approve');
	},
	filtersByAction : function(action){
		var list = new this.constructor();
		var length = this.attr('length');
		var current;
		for(var i = 0; i < length; i++){
			current = this.attr(i);
			if(current.attr('action') === action){
				list.push(current);
			}
		}
		list.attr('action', action);
		return list;
	},
	addFilter : function(embedId){
		var filter = new ModerationRuleset({action: this.attr('action'), embed_id: embedId});
		filter.addQuery();
		this.push(filter);
	},
	removeFilter : function(filter){
		var index = this.indexOf(filter);

		if(index > -1){
			this.splice(index, 1);
		}
	},
	saveOrDestroy : function(){
		return $.when.apply($, can.map(this, function(f){
			f.saveOrDestroy();
		}));
	}
});

export default ModerationRuleset;
