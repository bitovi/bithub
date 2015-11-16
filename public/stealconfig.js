(function () {

	require('./bower.json!bower');

	// Using `this` for web workers while maintaining compatibility with browser
	// targeted script loaders such as Browserify or Webpack where the only way to
	// get to the global object is via `window`.
	// taking from HTML5 Shiv v3.6.2 | @afarkas @jdalton @jon_neal @rem | MIT/GPL2 Licensed
	var supportsUnknownElements = false;

	(function () {
		try {
			var a = document.createElement('a');
			a.innerHTML = '<xyz></xyz>';

			supportsUnknownElements = a.childNodes.length == 1 || (function () {
				// assign a false positive if unable to shiv
				(document.createElement)('a');
				var frag = document.createDocumentFragment();
				return (
					typeof frag.cloneNode == 'undefined' ||
						typeof frag.createDocumentFragment == 'undefined' ||
						typeof frag.createElement == 'undefined'
				);
			}());
		} catch (e) {
			// assign a false positive if detection fails => unable to shiv
			supportsUnknownElements = true;
		}
	}());


	System.config({
		map: {
			"can/util/util": "can/util/jquery/jquery",
			"jquery/jquery": "jquery",
			'funcunit/funcunit' : 'funcunit',
			"moment/moment" : "moment",
			"selectize/selectize" : "selectize",
			"sifter.js" : "sifter",
			"microplugin.js" : "microplugin",
			"chart/chart" : "chart",
			"randomcolor/randomcolor" : "randomcolor",
			"opensourced-bithub/opensourced-bithub" : "opensourced-bithub",
			"jquerypayment/jquerypayment" : "jquerypayment"
		},
		paths: {
			"jquery": "bower_components/jquery/jquery.js",
			"can/*": "bower_components/canjs/steal/can/*.js",
			"lodash/*": "bower_components/lodash-amd/modern/*.js",
			'funcunit' : 'bower_components/funcunit/dist/funcunit.js',
			"moment" : "bower_components/moment/moment.js",
			"sifter" : 'bower_components/sifter/sifter.js',
			"microplugin" : 'bower_components/microplugin/src/microplugin.js',
			"selectize" : "bower_components/selectize/dist/js/selectize.js",
			"chart" : "bower_components/Chart.js/Chart.js",
			"randomcolor" : "bower_components/randomcolor/randomColor.js",
			"opensourced-bithub/*" : "node_modules/opensourced-bithub/*.js",
			"jquerypayment" : "bower_components/jquery.payment/lib/jquery.payment.js"
		},
		meta: {
			jquery: {
				exports: "jQuery",
				deps: supportsUnknownElements ? undefined : ["can/lib/html5shiv.js"]
			},
			jquerypayment : {
				deps : ["jquery"]
			},
			funcunit : {
				exports : 'FuncUnit',
				deps : ['jquery']
			},
			stripe : {
				exports: "Stripe"
			},
			chart : {
				exports: "Chart"
			}
		},
		ext: {
			ejs: "can/view/ejs/system",
			mustache: "can/view/mustache/system",
			stache: "can/view/stache/system"
		}
	});
})();


System.buildConfig = {map: {"can/util/util" : "can/util/domless/domless"}};
