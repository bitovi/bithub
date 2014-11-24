steal(
'can/component',
'./twitter-timeline.stache!',
'./twitter-timeline.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-timeline-service',
    template : initView,
    scope : {

    }
  });
});
