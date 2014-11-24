steal(
'can/component',
'./sidebar.stache!',
'./sidebar.less!',
'components/services',
function(Component, initView){
	return Component.extend({
		tag : 'bh-sidebar',
		template : initView,
		events : {
			inserted : 'setPanelHeight',
			'{window} resize' : 'setPanelHeight',
			'{can.route} panel' : function(){
				var self = this;
				setTimeout(function(){
					self.setPanelHeight();
				}, 1);
			},
			setPanelHeight: function(){
				var containerHeight = this.element.height(),
					headerHeight = this.element.find('.header').outerHeight(),
					hubNameHeight = this.element.find('.hub-name-wrap').outerHeight() + 29, // height + margin
					linksHeight = (4 * 37),
					totalHeight = headerHeight + hubNameHeight + linksHeight + 50; // add padding
				this.element.find('.panel-container').height(containerHeight - totalHeight)
			}
		},
		helpers : {
			linkToPanel : function(panel){
				panel = can.isFunction(panel) ? panel() : panel;
				return can.route.url({panel: panel}, true);
			},
			isPanel : function(panel, opts){
				panel = can.isFunction(panel) ? panel() : panel;
				return panel === can.route.attr('panel') ? opts.fn(this) : opts.inverse(this);
			}
		}
	});
});