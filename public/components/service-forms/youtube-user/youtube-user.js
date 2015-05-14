steal(
'can/component',
'./youtube-channel.stache!',
'./youtube-channel.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-youtube-user-service',
    template : initView,
    scope : {

    }
  });
});
