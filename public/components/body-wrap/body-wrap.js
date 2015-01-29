steal(
'can/component',
'./body-wrap.stache!',
'./body-wrap.less!',
'can/construct/proxy',
function(Component, initView){
	return Component.extend({
		tag: 'bh-body-wrap',
		template : initView,
		scope : {
			toggleExpanded : function(){
				this.attr('isExpanded', !this.attr('isExpanded'));
			}
		},
		events : {
			inserted : function(){
				var imgs = this.element.find('img');
				imgs.wrap('<div class="img-wrap"></div>');
				imgs.on('load', this.proxy('recalculateHeight'));
				setTimeout(this.proxy('recalculateHeight'), 1);
			},
			recalculateHeight : function(){
				var wrap = this.element.find('.body-wrap');
				var scrollHeight = wrap[0].scrollHeight;
				var height = wrap.height();

				this.scope.attr('isTooTall', height < scrollHeight);

			}
		}
	})
})