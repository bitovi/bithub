steal(
'can/component',
'./instagram-tag.stache!',
'./instagram-tag.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-instagram-tag-service',
    template : initView,
    scope : {

    }
  });
});
