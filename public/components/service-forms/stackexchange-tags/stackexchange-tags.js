steal(
'can/component',
'./stackexchange-tags.stache!',
'./stackexchange-tags.less!',
'components/tag-list',
function(Component, initView){
  return Component.extend({
    tag : 'bh-stackexchange-tags-service',
    template : initView,
    scope : {

    }
  });
});
