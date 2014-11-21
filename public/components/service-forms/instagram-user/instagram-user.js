steal(
'can/component',
'./instagram-user.stache!',
'./instagram-user.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-instagram-user-service',
    template : initView,
    scope : {

    }
  });
});
