steal(
'can/view/stache',
'lodash/collections/reduce.js',
function(stache, _reduce){

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

})