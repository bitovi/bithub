steal(
'can/component',
'./tumblr-blog.stache!',
'./tumblr-blog.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-tumblr-blog-service',
    template : initView,
    scope : {

    }
  });
});
