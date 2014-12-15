steal(
'can/component',
'models',
'./services-list.stache!',
'./services-list.less!',
'can/map/define',
function(Component, Models, initView){

	var formatKey = function(key){
		if(key === 'url') return 'URL';
		return can.capitalize(key.replace(/_/g, ' '));
	}

	var formatConfig = function(config){
		var res = ['<ul class="config">'];
		for(var k in config){
			res.push('<li><b>' + formatKey(k) + '</b>: ');
			if(can.isPlainObject(config[k])){
				res.push(formatConfig(config[k]));
			} else {
				res.push(config[k]);
			}
			res.push('</li>');
		}
		res.push('</ul>')
		return res.join('');
	}

	return Component.extend({
		tag : 'bh-services-list',
		template : initView,
		scope: {
			destroyService: function( service, el, ev) {
				if( confirm('Are you sure?') ) {
					service.destroy();
				}
			},
			editService:function(service){
				this.attr('currentService', service);
			}
		},
		helpers : {
			isCurrentService : function(service, opts){
				console.log(this.attr())
				service = can.isFunction(service) ? service() : service;
				return service === this.attr('currentService') ? opts.fn(opts.scope.add(service)) : opts.inverse(opts.scope.add(service));
			},
			formatConfig : function(config){
				config = can.isFunction(config) ? config() : config;
				return formatConfig(config.attr());
			}
		}
	});
});
