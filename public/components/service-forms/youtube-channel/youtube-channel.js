steal(
'can/component',
'./youtube-channel.stache!',
'./youtube-channel.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-youtube-channel-service',
    template : initView,
    scope : {

    }
  });
});
