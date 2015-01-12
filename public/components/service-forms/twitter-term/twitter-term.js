steal(
'can/component',
'./twitter-term.stache!',
'./twitter-term.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-term-service',
    template : initView,
    scope : {

    }
  });
});
