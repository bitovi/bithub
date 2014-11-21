steal(
'can/component',
'./foursquare-venue.stache!',
'./foursquare-venue.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-foursquare-venue-service',
    template : initView,
    scope : {

    }
  });
});
