steal(
'can/component',
'./rss-site.stache!',
'./rss-site.less!',
function(Component, initView){
  return Component.extend({
    tag : 'bh-rss-site-service',
    template : initView,
    scope : {

    }
  });
});
