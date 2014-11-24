steal(
'can/component',
'./twitter-search.stache!',
'./twitter-search.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-twitter-search-service',
    template : initView,
    scope : {

    }
  });
});
