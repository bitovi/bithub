steal(
'can/component',
'./tumblr-tag.stache!',
'./tumblr-tag.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-tumblr-tag-service',
    template : initView,
    scope : {

    }
  });
});
