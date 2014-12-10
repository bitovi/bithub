steal(
'can/component',
'./github-private-repo.stache!',
'./github-private-repo.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-github-private-repo-service',
    template : initView,
    scope : {

    }
  });
});
