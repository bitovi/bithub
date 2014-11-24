steal(
'can/component',
'./meetup-group.stache!',
'./meetup-group.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-meetup-group-service',
    template : initView,
    scope : {

    }
  });
});
