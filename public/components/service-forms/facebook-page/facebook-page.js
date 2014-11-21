steal(
'can/component',
'./facebook-page.stache!',
'./facebook-page.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-facebook-page-service',
    template : initView,
    scope : {

    }
  });
});
