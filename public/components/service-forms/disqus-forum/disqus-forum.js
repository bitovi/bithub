steal(
'can/component',
'./disqus-forum.stache!',
'./disqus-forum.less!',
'components/suggestions',
function(Component, initView){
  return Component.extend({
    tag : 'bh-disqus-forum-service',
    template : initView,
    scope : {

    }
  });
});
