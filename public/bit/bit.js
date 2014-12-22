steal(
'can/component',
'./bit.stache!',
'./bit.less!',
function(Component, initView){
	return Component.extend({
		tag: 'bh-bit',
		template : initView,
		events : {
			inserted : function(){
				var self = this;
				setTimeout(function(){
					console.log(self.scope.attr())
					if(self.scope.attr('bit._isFromLiveService')){
						self.element.trigger('bitInserted');
					}
				}, 4);
			}
		}
	})
})