steal(
'can/component',
'./tumblr-tags.stache!',
'./tumblr-tags.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-tumblr-tags-service',
    template : initView,
    scope : {

    }
  });
});
