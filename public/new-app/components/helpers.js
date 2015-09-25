import stache from "can/view/stache/";
import _reduce from "lodash-amd/modern/collection/reduce";


var getHash = function(optsHash){
	return _reduce(optsHash || {}, function(acc, val, key){
		acc[key] = can.isFunction(val) ? val() : val;
		return acc;
	}, {});
};

stache.registerHelper('pageUrl', function(page, opts){
	var hash = getHash(opts.hash);
	hash.page = can.isFunction(page) ? page() : page;
	return can.route.url(hash, false);
});

stache.registerHelper('tabUrl', function(tab){
	tab = can.isFunction(tab) ? tab() : tab;
	return can.route.url({tab: tab}, true);
});

stache.registerHelper('configErrors', function(errors, key, opts){
	var res;
	
	errors = can.isFunction(errors) ? errors() : errors;
	key = can.isFunction(key) ? key() : key;

	if(errors){
		errors = errors.attr(key) || [];

		if(!errors.length){
			 return;
		}

		res = ['<div class="alert alert-danger alert-error-list"><ul class="list-unstyled">'];
		for(var i = 0; i < errors.length; i++){
			res.push('<li>' + errors[i] + '</li>');
		}
		res.push('</ul></div>');
		return res.join('');
	}
});

stache.registerHelper('ifCanAddService', function(services, feed, type, opts){
	console.log('ifCanAddService helper called')

	return true ? opts.fn() : opts.inverse();
});
