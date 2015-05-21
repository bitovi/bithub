steal('can/model', function(Model){
	return Model.extend({
		create : 'POST /api/v3/interactions',
		createScrollInteraction : function(hubId){
			return this.create({
				primary_source_id: hubId,
				primary_source_type: 'Embed',
				event_type: 'scroll'
			});
		},
		createLinkClickedInteraction : function(hubId, entityId){
			return this.create({
				primary_source_id: hubId,
				primary_source_type: 'Embed',
				secondary_source_id: entityId,
				secondary_source_type: 'Entity',
				event_type: 'link'
			});
		},
		createEntitySharedInteraction : function(hubId, entityId, target){
			return this.create({
				primary_source_id: hubId,
				primary_source_type: 'Embed',
				secondary_source_id: entityId,
				secondary_source_type: 'Entity',
				event_type: 'share',
				event_subtype: 'target'
			});
		}
	}, {});
});
