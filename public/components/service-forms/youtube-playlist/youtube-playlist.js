steal(
'can/component',
'./youtube-channel.stache!',
'./youtube-channel.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-youtube-playlist-service',
    template : initView,
    scope : {

    }
  });
});
