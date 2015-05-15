steal(
'can/component',
'./youtube-user.stache!',
'./youtube-user.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-youtube-user-service',
    template : initView,
    scope : function(){
			console.log(arguments);
		}
  });
});
