steal(
'can/component',
'./twitter-hashtag.stache!',
'./twitter-hashtag.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-hashtag-service',
    template : initView,
    scope : {

    }
  });
});
