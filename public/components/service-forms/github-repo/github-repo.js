steal(
'can/component',
'./github-repo.stache!',
'./github-repo.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-github-repo-service',
    template : initView,
    scope : {

    }
  });
});
