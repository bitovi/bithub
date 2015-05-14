steal(
'can/component',
'./youtube-playlist.stache!',
'./youtube-playlist.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-youtube-playlist-service',
    template : initView,
    scope : {

    }
  });
});
