steal(
'can/component',
'./twitter-user_timeline.stache!',
'./twitter-user_timeline.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-user_timeline-service',
    template : initView,
    scope : {

    }
  });
});
