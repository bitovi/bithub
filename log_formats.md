crawler-listener
================


[2015-05-23 16:01:52][INFO]: Initializing Entity publisher
[2015-05-23 16:01:52][INFO]: Initializing Error publisher
[2015-05-23 16:01:52][INFO]: Initializing Notification publisher
[2015-05-23 16:01:52][INFO]: HTTP server listening on 0.0.0.0:3001
[2015-05-23 16:01:52][INFO]: Started HTTP handler for Handlers::Instagram::Subscriptions on url ["GET", "/instagram/media"]
[2015-05-23 16:01:52][INFO]: Started HTTP handler for Handlers::Instagram::Notifications on url ["POST", "/instagram/media"]
[2015-05-23 16:01:52][INFO]: Started HTTP handler for Handlers::Facebook::Subscriptions on url ["GET", "/facebook/page/feed"]
[2015-05-23 16:01:52][INFO]: Started HTTP handler for Handlers::Facebook::Notifications on url ["POST", "/facebook/page/feed"]
[2015-05-23 16:01:52][INFO]: Started HTTP handler for Handlers::Foursquare on url ["POST", "/foursquare/venues"]
[2015-05-23 16:01:54][INFO]: Starting ROOT/MAIN supervisor

even pub
--------
[warm_reef_2843_20 billowing_pine_4197 3 facebook page] Failed to dispatch to a feed in Events
[%brand_name% %embed_name% %service_id% %feed_name% %type_name%] %message%

[merry_dove_2868 undisturbed_brook_4825 68 instagram tag] Published 0 new events out of total 1
[%brand_name% %embed_name% %service_id% %feed_name% %type_name%] Published %num% events of total %num_total%J


fb postback
-----------
POST /api/postback/facebook/page/feed

? Facbook postback notification for page 313013458732315


instagram postback
------------------
POST /api/postback/instagram/media

instagram unsub
---------------
Unsubscribing from Instagram service for user 28912606



crawler-poller
==============

event pub
---------

[calm_dove_6826 bump club and beyond (payal) 49 twitter user_timeline] Published 0 new events out of total 200
[%brand_name% %embed_name% %service_id% %feed_name% %type_name%] %message% 


command pub
-----------

Publishing COMMAND {:service=>{:id=>162, :has_errors=>false}} to backend

Publishing COMMAND {:service=>{:id=>162, :has_errors=>false}} to frontend



listener
========

Listener connected to AMQP, queue name: q.web.commands

Validation failed: Title can't be blank | {:title=>["can't be blank"], :base=>[]}

[merry_dove_2868 undisturbed_brook_4825 68 instagram media_event] New Event received

New COMMAND received: {"service"=>{"id"=>12, "has_errors"=>false}}, brand: 'charming_volcano_7196_1'

Actor crashed!
Bunny::UnexpectedFrame: Connection-level error: UNEXPECTED_FRAME - expected content header for class 60, got non content header frame instead
