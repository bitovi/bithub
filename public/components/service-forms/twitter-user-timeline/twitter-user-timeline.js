steal(
'can/component',
'./twitter-user-timeline.stache!',
'./twitter-user-timeline.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-user-timeline-service',
    template : initView,
    scope : {

    }
  });
});
