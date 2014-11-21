steal(
'can/component',
'./github-org.stache!',
'./github-org.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-github-org-service',
    template : initView,
    scope : {

    }
  });
});
