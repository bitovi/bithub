steal(
'can/component',
'./twitter-followers.stache!',
'./twitter-followers.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-followers-service',
    template : initView,
    scope : {

    }
  });
});
